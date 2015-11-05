#include <stdio.h>
#include <stdlib.h>
#include <strings.h>
#include <string.h>
#include <sys/types.h>   // definitions of a number of data types used in socket.h and netinet/in.h
#include <sys/socket.h>  // definitions of structures needed for sockets, e.g. sockaddr
#include <netinet/in.h>  // constants and structures needed for internet domain addresses, e.g. sockaddr_in
#include <sys/time.h>

// Transmission settings
double LOSS_PROB = 0.01;
double CORRUPT_PROB = 0.01;

// GBN settings
#define GO_BACK_N 5

// Congestion control settings
#define THRESHOLD 6
#define REPEAT_TIME 3

// Server and client settings
#define MAX_RESEND_TIME 100
long CLIENT_TIMEOUT_SEC = 1;
long CLIENT_TIMEOUT_MSEC = 0;
long SERVER_TIMEOUT_SEC = 0;
long SERVER_TIMEOUT_MSEC = 100000;

// Packet setting
#define DATA_SIZE 1000
#define MAX_FILE_SIZE 2147483647

/*
* Data structure for packet in our GBN implementation
* Type indicates what kind of packet it is
* 0 - Request
	  length: length of data
	  seq_no: use_congestion control
	  data: file path
* 1 - data
* 	  seq_no: offset of data in the file
*	  length: length of data
*	  fin: wheter it is the last data packet
*     data: data
* 2 - ACK
	  seq_no: The next packet to be sent
* 3 - corrupted
*/
struct packet{
  int type;
  int seq_no;
  int length;
  int fin;
  char data[DATA_SIZE];
};

/* Print error and exit */
void error(char *msg)
{
    perror(msg);
    exit(0);
}

/* Generate a random number between 0 and 1 */
double random_num()
{
	return (double)rand() / (double)RAND_MAX;
}

/* Get current time in mu sec(sec*10e6) */
long get_current_time()
{
	struct timeval cur_time;
	gettimeofday(&cur_time, NULL); 
	return(cur_time.tv_sec * 1000000 + cur_time.tv_usec);
}

/* Get sec part from time in mu sec */
long get_sec(long time_in_msec)
{
	return(time_in_msec/1000000);
}

/* Get mu sec part from time in mu sec */
long get_msec(long time_in_msec)
{
	return(time_in_msec%1000000);
}

/* Return if there will be a packet returned in a given amount of time  */
int select_for_sock(int sockfd, long sec, long msec)
{
    fd_set readfds, masterfds;
    struct timeval timeout;
    
    timeout.tv_sec = sec;
	timeout.tv_usec = msec; 
    FD_ZERO(&masterfds);
    FD_SET(sockfd, &masterfds);
    memcpy(&readfds, &masterfds, sizeof(fd_set));

    if (select(sockfd+1, &readfds, NULL, NULL, &timeout) < 0) {
        error("ERROR on select");
    }
    return(FD_ISSET(sockfd, &readfds));
}

/* Create a corrupted packet */
void create_corrupted_pkt(struct packet *pkt)
{
    pkt->type = 3;
}

/* Send a packet */
void send_pkt(int sockfd, struct packet *pkt, struct sockaddr *target_addr, socklen_t *target_len)
{
	int is_loss = (pkt->type != 0 && random_num() < LOSS_PROB);
	int is_corrupted = (pkt->type != 0 && random_num() < CORRUPT_PROB);
    //if the packet is a request packet, it won't suffer from packet loss or corruption
    if(is_loss) {
    	printf("[%lu]SENT(LOST) PKT seq_no %d(%d bytes)\n", get_current_time(), pkt->seq_no, pkt->length);
    } else{
    	if(is_corrupted) create_corrupted_pkt(pkt);
	 	int msg_len;
	 	msg_len = sendto(sockfd, pkt, sizeof(*pkt), 0, target_addr, *target_len);

	 	long cur_time = get_current_time();

	 	if (msg_len < 0) error("ERROR writing to socket");
		if(pkt->type == 0) printf("[%lu]SENT REQUEST(%d bytes): %s\n", cur_time, pkt->length, pkt->data);
		if(pkt->type == 1) printf("[%lu]SENT DATA seq_no %d(%d bytes)\n", cur_time, pkt->seq_no, pkt->length);
		if(pkt->type == 2) printf("[%lu]SENT ACK %d\n", cur_time, pkt->seq_no);
		if(pkt->type == 3) printf("[%lu]SENT CORRUPTED\n", cur_time);
    }
}

/* Receive a packet */
void recv_pkt(int sockfd, struct packet *pkt, struct sockaddr *target_addr, socklen_t *target_len)
{
	int msg_len;
	msg_len = recvfrom(sockfd, pkt, sizeof(*pkt), 0, target_addr, target_len);

	long cur_time = get_current_time();
	
	if (msg_len < 0) error("ERROR receiving from socket");	
	if(pkt->type == 0) printf("[%lu]RECEIVED REQUEST(%d bytes): %s\n", cur_time, pkt->length, pkt->data);
	if(pkt->type == 1) printf("[%lu]RECEIVED DATA seq_no %d(%d bytes)\n", cur_time, pkt->seq_no, pkt->length);
	if(pkt->type == 2) printf("[%lu]RECEIVED ACK %d\n", cur_time, pkt->seq_no);
	if(pkt->type == 3) printf("[%lu]RECEIVED CORRUPTED\n", cur_time);
} 
