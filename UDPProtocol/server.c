/* A simple server in the internet domain using UDP modified from example given
   The port number is passed as an argument 
   This version runs forever.
*/
#include "packet.c"

/* Set up the connection for server */
int connection_setup(int portno,  struct sockaddr_in *cli_addr, int *cli_len)
{
	struct sockaddr_in serv_addr;
	int sockfd;

	// Creat a UDP socket
	sockfd = socket(AF_INET, SOCK_DGRAM, 0);
	if (sockfd < 0) 
	   error("ERROR opening socket");

	// Set up the server UDP config
	bzero((char *) &serv_addr, sizeof(serv_addr));
	serv_addr.sin_family = AF_INET;
	serv_addr.sin_addr.s_addr = INADDR_ANY;
	serv_addr.sin_port = htons(portno);
	
	// Bind Socket to local host and use the port number given
	if (bind(sockfd, (struct sockaddr *) &serv_addr, sizeof(serv_addr)) < 0) { 
		error("ERROR on binding");
	}
	
    // Set up server UDP config
	*cli_len = sizeof(*cli_addr);
	return(sockfd);
}

/* Create a data packet from a given file with a offset. Update sequence number and return if it gets to the EOF */
int create_data_pkt(struct packet *pkt, int *next_seq_no, FILE *input_file)
{
    pkt->type = 1;
    pkt->seq_no = *next_seq_no;

    // Get data
    fseek(input_file, *next_seq_no, SEEK_SET);
   	int m = fread(pkt->data, sizeof(char), DATA_SIZE-1, input_file);
   	pkt->data[m] = '\0';
    pkt->length = m;

    // Set fin
    fgetc(input_file);
   	if (feof(input_file)) {
   		pkt->fin = 1;	
   	} else {
   		pkt->fin = 0;
    }

    *next_seq_no = (*next_seq_no + m);

    return(pkt->fin);
}

/* Receive a request packet from socket. Return the path of file requested */
char* recv_req_pkt(int sockfd, struct packet *pkt, struct sockaddr *cli_addr, socklen_t *cli_len)
{
	char *full_path;
	while(1){
		recv_pkt(sockfd, pkt, cli_addr, cli_len);
		if(pkt->type == 0){
			full_path = malloc(strlen(pkt->data)+15);
	    	strcpy(full_path, "./server_data/");
	    	strcpy(full_path+14, pkt->data);
	    	return(full_path);
		}
		printf("%s\n","IGNORE PKT" );
	}
}

/* Send file using GBN */
void go_back_n(int sockfd, struct packet *pkt, struct sockaddr *cli_addr, socklen_t *cli_len, FILE *input_file)
{
    int next_seq_no = 0;
    int base = 0;
	int no_new_pkt = 0;
	int window_size = (DATA_SIZE-1)*GO_BACK_N;

	int use_timer = 0;
	long start_time, current_time, time_left;
	time_left = SERVER_TIMEOUT_SEC * 1000000 + SERVER_TIMEOUT_MSEC;

	fseek(input_file, 0, SEEK_END);
	int file_size = ftell(input_file);
	fseek(input_file, 0, SEEK_SET);

	int resend_base = -1;
	int resend_count = 0;
	
	// Send packets until base == file size.
    do{
    	// Space available to sent new packets
    	if((window_size - next_seq_no + base) >= (DATA_SIZE-1) && !no_new_pkt){
	      	no_new_pkt = create_data_pkt(pkt, &next_seq_no, input_file);
	     	send_pkt(sockfd, pkt, cli_addr, cli_len);
	      	if(!use_timer){
	      		use_timer = 1;
	      		start_time = get_current_time();
	      		time_left = SERVER_TIMEOUT_SEC * 1000000 + SERVER_TIMEOUT_MSEC;
	      	}
    	} else{ 
    		// Try to recieve an ACK packet
    		while(1){    
	    		if(use_timer == 0) error("ERROR: Getting ACK when no pkt is sent");
    			current_time = get_current_time();	
    			time_left -= (current_time - start_time);
    			if(time_left < 0) time_left = 0;
   	    		
   	    		// Get a packet
   	    		if(select_for_sock(sockfd, get_sec(time_left), get_msec(time_left))){
	   	    		recv_pkt(sockfd, pkt, cli_addr, cli_len);
	   	    		// Wrong packet type
	   	    		if(pkt->type != 2){
	   	    			continue;
	   	    		}
	   	    		// Get a right ACK
	   	    		if(pkt->seq_no > base){
	   	    			base = pkt->seq_no;
	   	    			start_time = get_current_time();
	   	    			time_left = SERVER_TIMEOUT_SEC * 1000000 + SERVER_TIMEOUT_MSEC;
	   	    			break;
	   	    		}
   	    		}else{ // Time out
   	    			printf("%s\n", ">>>>>>>>>>>>>>>>>>>>>>>TIME OUT>>>>>>>>>>>>>>>>>>>>>>>>>" );
   	    			next_seq_no = base;
   	    			no_new_pkt = 0;
   	    			use_timer = 0;

   	    			// We only want to resend the same packet for a given amount of time
					if(base == resend_base){
						resend_count++;
						if(resend_count == MAX_RESEND_TIME){
							printf("%s\n", "Client time out: Discard" );
							return;
						}
					}else{
						resend_base = base;
						resend_count = 0;
					}	

   	    			break;
   	    		}
          	}
    	}
    }while(base != file_size);
}

/* Send file using GBN with congestion control */
void congestion_control(int sockfd, struct packet *pkt, struct sockaddr *cli_addr, socklen_t *cli_len, FILE *input_file)
{
    int next_seq_no = 0;
    int base = 0;
	int no_new_pkt = 0;

	int cwnd = 1;
	printf("-----------CWND:%d\n", cwnd);
	int threshold = THRESHOLD;
	printf("-----------sstresh:%d\n", threshold);	
	int num_pkt_sent_unit_time = 0;
	int max_ack_no_unit_time;

	int count_repeat = 0;
	int on_repeat = 0;
	int count_receive = 0;

	int use_timer = 0;
	long start_time, current_time, time_left;
	time_left = SERVER_TIMEOUT_SEC * 1000000 + SERVER_TIMEOUT_MSEC;

	fseek(input_file, 0, SEEK_END);
	int file_size = ftell(input_file);
	fseek(input_file, 0, SEEK_SET);

	int resend_base = -1;
	int resend_count = 0;
	
	// Send packets until base == file size.
    do{
    	// Space available to sent new packets
    	if((cwnd*(DATA_SIZE-1) - next_seq_no + base) >= (DATA_SIZE-1) && !no_new_pkt){
	      	no_new_pkt = create_data_pkt(pkt, &next_seq_no, input_file);
	     	send_pkt(sockfd, pkt, cli_addr, cli_len);
	      	if(!use_timer){
	      		use_timer = 1;
	      		time_left = SERVER_TIMEOUT_SEC * 1000000 + SERVER_TIMEOUT_MSEC;
	      		start_time = get_current_time();
	      	}
	      	if(num_pkt_sent_unit_time<cwnd){
	      		num_pkt_sent_unit_time++;
	      		if(num_pkt_sent_unit_time == cwnd) max_ack_no_unit_time=pkt->seq_no + pkt->length;
	      	}else{
	      		num_pkt_sent_unit_time=1;
	      	}
	      	printf("SENT INDEX: %d\n", num_pkt_sent_unit_time);
    	} else{
    		// Try to recieve an ACK packet    	
    		while(1){    
	    		if(use_timer == 0) error("ERROR: Getting ACK when no pkt is sent");
    			current_time = get_current_time();	
    			time_left -= (current_time - start_time);
    			if(time_left < 0) time_left = 0;

   	    		// Get a packet   	    		
   	    		if(select_for_sock(sockfd, get_sec(time_left), get_msec(time_left))){
	   	    		recv_pkt(sockfd, pkt, cli_addr, cli_len);
	   	    		if(pkt->type != 2){
	   	    			continue;
	   	    		}
	   	    		// Get the right ACK
	   	    		if(pkt->seq_no > base){
	   	    			count_repeat = 0;
	   	    			on_repeat = 0;
	   	    			count_receive++;
	   	    			printf("RECEIVE INDEX: %d\n", count_receive);
	   	    			base = pkt->seq_no;
	   	    			// Get all ACK within the window, update cwnd and threshold
	   	    			if(!no_new_pkt && base >= max_ack_no_unit_time){
	   	    				if (cwnd*2 < threshold) {
	   	    					cwnd *= 2;
	   	    				}else{
	   	    					cwnd += 1;
	   	    				}
	   	    				count_receive = 0;	
	   	    				printf("\n-----------CWND:%d\n", cwnd);
	   	    				printf("-----------sstresh:%d\n", threshold);	
	   	    			}
	   	    			start_time = get_current_time();
	   	    			time_left = SERVER_TIMEOUT_SEC * 1000000 + SERVER_TIMEOUT_MSEC;
	   	    			break;
	   	    		// Wrong ACK, check fast recovery	
	   	    		}else if(pkt->seq_no == base && !on_repeat){
	   	    			count_repeat++;
	   	    			// Start fast recovery
	   	    			if(count_repeat == REPEAT_TIME){
		   	    			printf("\n%s\n", ">>>>>>>>>>>>>>>>>>>>>>>FAST RECOVERY>>>>>>>>>>>>>>>>>>>>>>>>>" );
		   	    			next_seq_no = base;
		   	    			no_new_pkt = 0;
		   	    			use_timer = 0;
		   	    			threshold = cwnd / 2;
		   	    			if(threshold < 2) threshold = 2;
		   	    			cwnd = threshold + 3;
		   	    			num_pkt_sent_unit_time = 0;
							max_ack_no_unit_time = 0;
							count_repeat = 0;
							on_repeat = 1;
							count_receive = 0;

							// We only want to resend the same packet a given amount of times
							if(base == resend_base){
								resend_count++;
								if(resend_count == MAX_RESEND_TIME){
									printf("%s\n", "Client time out: Discard" );
									return;
								}
							}else{
								resend_base = base;
								resend_count = 0;
							}	
			   	    		printf("\n-----------CWND:%d\n", cwnd);
			   	    		printf("-----------sstresh:%d\n", threshold);	
		   	    			break;
	   	    			}
	   	    		}
   	    		}else{ //timeout
   	    			printf("\n%s\n", ">>>>>>>>>>>>>>>>>>>>>>>TIME OUT>>>>>>>>>>>>>>>>>>>>>>>>>" );
   	    			next_seq_no = base;
   	    			no_new_pkt = 0;
   	    			use_timer = 0;
   	    			threshold = cwnd / 2;
   	    			if(threshold < 2) threshold = 2;
   	    			cwnd = threshold + 3;
   	    			num_pkt_sent_unit_time = 0;
					max_ack_no_unit_time = 0;

					// We only want to resend the same packet a given amount of times
					if(base == resend_base){
						resend_count++;
						if(resend_count == MAX_RESEND_TIME){
							printf("%s\n", "Client time out: Discard" );
							return;
						}
					}else{
						resend_base = base;
						resend_count = 0;
					}	

	   	    		printf("\n-----------CWND:%d\n", cwnd);
	   	    		printf("-----------sstresh:%d\n", threshold);	
   	    			break;
   	    		}
          	}
    	}
    }while(base != file_size);
}

int main(int argc, char *argv[])
{
	// Socket info
	int sockfd;
	socklen_t cli_len;
	struct sockaddr_in cli_addr;
	
	// Buffer related
	struct packet pkt;
	int client_congestion_control;
	int server_congestion_control;

	// Check input arguments is valid: argv[1]: port number
	if (argc < 3) {
	    fprintf(stderr,"usage %s port enable_congestion_control\n", argv[0]);
	    exit(1);
	}
	server_congestion_control = atoi(argv[2]);
		
	// Setup connection	
	sockfd = connection_setup(atoi(argv[1]), &cli_addr, &cli_len);

    // Set seed for random number
	srand(0);

	// Start receiving request messages from clients
	while (1) {
		// Receive a request
	    char* file_path = recv_req_pkt(sockfd, &pkt, (struct sockaddr *)&cli_addr, &cli_len);
	    client_congestion_control = pkt.seq_no;
	    FILE *input_file = fopen(file_path, "rb");

	    // File path should be valid
	    if(!input_file){
	    	printf("Can't open file: %s\n", file_path);
	    	continue;
	    }

	    // File size can't be 0 or more than 2G
	    fseek(input_file, 0, SEEK_END);
		long file_size = ftell(input_file);
		fseek(input_file, 0, SEEK_SET);
		if(file_size ==0 || file_size > MAX_FILE_SIZE){
			printf("File size is 0 or file size too large: %s\n", file_path);
			continue;
		}

		// Start sending file
	    if(!server_congestion_control || ! client_congestion_control){
	    	go_back_n(sockfd, &pkt, (struct sockaddr *)&cli_addr, &cli_len, input_file);
	    }else{
	    	congestion_control(sockfd, &pkt, (struct sockaddr *)&cli_addr, &cli_len, input_file);
	    }

      	fclose(input_file);
      	printf("\n=================FINISH=====================\n\n");
	} /* end of while */
	return 0; /* we never get here */
}
