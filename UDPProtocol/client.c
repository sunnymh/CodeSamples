
/*
 A simple client in the internet domain using UDP
 Usage: ./client hostname port (./client 192.168.0.151 10000)
 */
#include <netdb.h>      // define structures like hostent
#include <libgen.h>
#include "packet.c"

/* Set up the connection for client */
int connection_setup(char *hostname, int host_portno, struct sockaddr_in *serv_addr, int *serv_len)
{
    struct sockaddr_in cli_addr;
    struct hostent *server; //contains tons of information, including the server's IP address
    int sockfd;

    // Creat a UDP socket    
    sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    if (sockfd < 0) 
        error("ERROR opening socket");

    // Set up client UDP config
    bzero((char *) &cli_addr, sizeof(cli_addr));
    cli_addr.sin_family = AF_INET;
    cli_addr.sin_addr.s_addr = INADDR_ANY;
    cli_addr.sin_port = htons(0);
    
    // Bind Socket to local host and use the port number given
    if (bind(sockfd, (struct sockaddr *) &cli_addr, sizeof(cli_addr)) < 0) { 
        error("ERROR on binding");
    }
    
    // Get host info
    server = gethostbyname(hostname); //takes a string like "www.yahoo.com", and returns a struct hostent which contains information, as IP address, address type, the length of the addresses...
    if (server == NULL) {
        fprintf(stderr,"ERROR, no such host\n");
        exit(0);
    }

    // Set up server UDP config
    *serv_len = sizeof(*serv_addr);
    bzero((char *) serv_addr, *serv_len);
    serv_addr->sin_family = AF_INET; //initialize server's address
    bcopy((char *)server->h_addr, (char *)&serv_addr->sin_addr.s_addr, server->h_length);
    serv_addr->sin_port = htons(host_portno);

    return(sockfd);
}

/* Create a request packet */
void create_req_pkt(struct packet *pkt, char *path, int use_congestion_control)
{
    pkt->type = 0;
    pkt->seq_no = use_congestion_control;
    pkt->length = strlen(path);
    pkt->fin = -1;
    strcpy(pkt->data, path);
}

/* Create an ACK pkt */
void create_ack_pkt(struct packet *pkt, int expct_seq_no)
{
    pkt->type = 2;
    pkt->seq_no = expct_seq_no;
    pkt->length = 0;
    pkt->fin = -1;
    pkt->data[0] = '\0';
}

/* Receive a data packet */
void recv_data_pkt(int sockfd, struct packet *pkt, struct sockaddr *serv_addr, socklen_t *serv_len)
{
    while(1){

        if (select_for_sock(sockfd, CLIENT_TIMEOUT_SEC, CLIENT_TIMEOUT_MSEC)) {
            recv_pkt(sockfd, pkt, serv_addr, serv_len);
            if(pkt->type == 1) break;
        } else{
            error("ERROR server time out. Reason could be:\n1. Server not running.\n2. File not exist.\n3. File size is 0.\n4. File size more than 2G.\n5. Communication too noisy\n");
        }
    }
}

int main(int argc, char *argv[])
{
    // Socket info
    int sockfd;
    socklen_t serv_len;
    struct sockaddr_in serv_addr;

    // Buffer related
    struct packet pkt;

    // Check input arguments is valid: argv[1]: host address, argv[2]: port number
    if (argc < 5) {
       fprintf(stderr,"usage %s hostname port path enable_congestion_control\n", argv[0]);
       exit(0);
    }

    // File path has to be stored within 1 request packet
    if (strlen(argv[3]) > 999) {
       fprintf(stderr,"File path can't be more than 999 bytes:\n", argv[3]);
       exit(0);        
    }

    // Setup connection 
    sockfd = connection_setup(argv[1], atoi(argv[2]), &serv_addr, &serv_len);

    // Set seed for random number
    srand(0);

    // Send request message
    char* file_name = basename(argv[3]);
    if(!file_name) error("ERROR invalid path");
    create_req_pkt(&pkt, argv[3], atoi(argv[4]));
    send_pkt(sockfd, &pkt, (struct sockaddr *)&serv_addr, &serv_len);

    // Prepare the file to write
    char* file_path = malloc(strlen(file_name)+15);
    strcpy(file_path, "./client_data/");
    strcpy(file_path+14, file_name);
    FILE *input_file = fopen(file_path, "w");
    int expct_seq_no = 0;
    int fin = 0;

    // Get data packets
    do{
        recv_data_pkt(sockfd, &pkt, (struct sockaddr *)&serv_addr, &serv_len);
        
        if (pkt.seq_no == expct_seq_no){
            fwrite(pkt.data, sizeof(char), pkt.length, input_file);
            expct_seq_no += pkt.length;
            fin = pkt.fin;            
        }
        create_ack_pkt(&pkt, expct_seq_no);
        send_pkt(sockfd, &pkt, (struct sockaddr *)&serv_addr, &serv_len);        

    }while(!fin);

    fclose(input_file); 

    // Make sure the last ACK is received
    while(1){

        if (select_for_sock(sockfd, CLIENT_TIMEOUT_SEC, CLIENT_TIMEOUT_MSEC)) {
            recv_pkt(sockfd, &pkt, (struct sockaddr *)&serv_addr, &serv_len);
            create_ack_pkt(&pkt, expct_seq_no);
            send_pkt(sockfd, &pkt, (struct sockaddr *)&serv_addr, &serv_len);                
        } else{
            break;
        }
    }

    close(sockfd); //close socket
    
    return 0;
}
