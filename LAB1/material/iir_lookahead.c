#include <stdio.h>
#include <stdlib.h>

#define N 2 /// order of the filter
#define NB 12 /// number of bits
#define TRUNCATED_BITS NB+5 /// number of bits to throw away

const int b0 = 423;
const int b[N+1] = {1002, 735, 156};
const int a[N+1] = {0, -122, -149};

/// This function performs the fixed point filtering of the lookahead version of
/// the filter assuming direct form II
///\param x is the new input sample
///\return the new output sample
int lookaheadIIR(int x)
{
    static int sw[N+1]; /// w shift register (static: needs to retain content)
    static int first_run = 0; /// first run flag
    int i; /// index
    int w; /// intermediate value 
    int y; /// output sample
    int fb, ff; /// feed-back and feed-forward results
     
    /// clean the buffer (= reset the registers) during the first run
    if (first_run == 0) {
        first_run = 1;
        for (i = 0; i < N+1; i++) {
            sw[i] = 0;
        }
    }
    
    fb = 0;
    ff = 0;
    
    /// compute feedback with the data inside the shift register
    for (i = 0; i < N+1; i++) {
        /// product and truncation after product to 7 bits only
        fb += (sw[i]*a[i]) >> (TRUNCATED_BITS-1);
		ff += (sw[i]*b[i]) >> (TRUNCATED_BITS-1);
    }
    
    /// compute intermediate value (w) and output sample
    w = x + (fb << 5);    
    
    /// update the shift register and compute the values of the pipe registers
    y = (w*b0) >> (TRUNCATED_BITS - 1);

    y += ff;

    for (i = N; i > 0; i--) {
        sw[i] = sw[i-1];
	}

    sw[0] = w;
    
    return (y << 5);
}

int main(int argc, char **argv)
{
    FILE *fp_in;
    FILE *fp_out;
    
    int x;
    int y;
    
    /// check the command line
    if (argc != 3) {
        printf("Use: %s <input_file> <output_file>\n", argv[0]);
        exit(1);
    }
    
    /// open files
    fp_in = fopen(argv[1], "r");
    if (fp_in == NULL) {
        printf("Error: cannot open %s\n");
        exit(2);
    }
    fp_out = fopen(argv[2], "w");
    
    /// get samples and apply filter
    fscanf(fp_in, "%d", &x);
    do {
	    y = lookaheadIIR(x);
        fprintf(fp_out,"%d\n", y);
	    fscanf(fp_in, "%d", &x);
    } while (!feof(fp_in));

    fclose(fp_in);
    fclose(fp_out);

    return 0;
}
