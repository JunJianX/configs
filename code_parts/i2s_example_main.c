/* I2S Example

    This example code will output 100Hz sine wave and triangle wave to 2-channel of I2S driver
    Every 5 seconds, it will change bits_per_sample [16, 24, 32] for i2s data

    This example code is in the Public Domain (or CC0 licensed, at your option.)

    Unless required by applicable law or agreed to in writing, this
    software is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
    CONDITIONS OF ANY KIND, either express or implied.
*/
#include <stdio.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "driver/i2s.h"
#include "esp_system.h"
#include <math.h>
// #include "data.h"
// #include "data2.h"
// #include "data3.h"
#include "data4.h"
#include <string.h>

// extern const  unsigned char  TestAudioBlk0[];

#define SAMPLE_RATE     (44100)
#define I2S_NUM         (0)
#define WAVE_FREQ_HZ    (100)
#define PI              (3.14159265)
#define I2S_BCK_IO      (GPIO_NUM_5)
#define I2S_WS_IO       (GPIO_NUM_25)
#define I2S_DO_IO       (GPIO_NUM_35)
#define I2S_DI_IO       (-1)

#define TICK            (100)

#define SAMPLE_PER_CYCLE (SAMPLE_RATE/WAVE_FREQ_HZ)


#define GPIO_OUTPUT_IO_0    18
#define GPIO_OUTPUT_IO_1    19
#define GPIO_OUTPUT_PIN_SEL  ((1<<GPIO_OUTPUT_IO_0) | (1<<GPIO_OUTPUT_IO_1))
static uint32_t count = 0;
/*
static void setup_triangle_sine_waves(int bits)
{
    int *samples_data = malloc(((bits+8)/16)*SAMPLE_PER_CYCLE*4);
    unsigned int i, sample_val;
    double sin_float, triangle_float, triangle_step = (double) pow(2, bits) / SAMPLE_PER_CYCLE;
    size_t i2s_bytes_write = 0;

    printf("\r\nTest bits=%d free mem=%d, written data=%d\n", bits, esp_get_free_heap_size(), ((bits+8)/16)*SAMPLE_PER_CYCLE*4);

    triangle_float = -(pow(2, bits)/2 - 1);

    for(i = 0; i < SAMPLE_PER_CYCLE; i++) {
        sin_float = sin(i * PI / 180.0);
        if(sin_float >= 0)
            triangle_float += triangle_step;
        else
            triangle_float -= triangle_step;

        sin_float *= (pow(2, bits)/2 - 1);

        if (bits == 16) {
            sample_val = 0;
            sample_val += (short)triangle_float;
            sample_val = sample_val << 16;
            sample_val += (short) sin_float;
            samples_data[i] = sample_val;
        } else if (bits == 24) { //1-bytes unused
            samples_data[i*2] = ((int) triangle_float) << 8;
            samples_data[i*2 + 1] = ((int) sin_float) << 8;
        } else {
            samples_data[i*2] = ((int) triangle_float);
            samples_data[i*2 + 1] = ((int) sin_float);
        }

    }

    i2s_set_clk(I2S_NUM, SAMPLE_RATE, bits, 2);
    //Using push
    // for(i = 0; i < SAMPLE_PER_CYCLE; i++) {
    //     if (bits == 16)
    //         i2s_push_sample(0, &samples_data[i], 100);
    //     else
    //         i2s_push_sample(0, &samples_data[i*2], 100);
    // }
    // or write
    i2s_write(I2S_NUM, samples_data, ((bits+8)/16)*SAMPLE_PER_CYCLE*4, &i2s_bytes_write, 100);

    free(samples_data);
}
*/
/*
static void send_data(void)
{
    static uint32_t count = 0;
    size_t i2s_bytes_write = 0;
    uint16_t num =SAMPLE_RATE*TICK*4/1000;
    int *samples_data = malloc(num);
    memset(samples_data,0x00,num);
    memcpy(samples_data,TestAudioBlk0+count,num);
   
    i2s_write(I2S_NUM, samples_data, 882, &i2s_bytes_write, 100);
    // count += i2s_bytes_write; 
    free(samples_data);
}
*/
/*
static void send_data2(void)
{
    size_t i2s_bytes_write = 0;
    uint16_t num =SAMPLE_RATE*TICK*4/1000;//882
    char *samples_data = malloc(num);
    // printf("%d\r\n",num);
    memset(samples_data,0x00,num);
    // memcpy(samples_data,TestAudioBlk0+count,num); 
    // for(uint16_t i =0;i<num/4;i++)
    // {
    //     samples_data[i*4+0]=
    //     samples_data[i*4+1]=
    //     samples_data[i*4+2]=
    //     // samples_data[i*4+3]=0x00;
    // }

    
    for(uint16_t i =0;i<num/4;i++)
    {
        // memcpy(samples_data+4*i,TestAudioBlk2+count,3);
        // printf("%d,%d\r\n",i,count);
        // memcpy(samples_data,TestAudioBlk2,3);
        memcpy(samples_data+4*i+1,TestAudioBlk2+count,2);
        count +=2;
    }
    // printf("%d\r\n",count);
    if(count +10>sizeof(TestAudioBlk2))
    {
        count = 0;
    }
   
    i2s_write(I2S_NUM, samples_data, 882, &i2s_bytes_write, 100);
    // count += i2s_bytes_write; 
    free(samples_data);
}
*/

/*
static void send_data3()
{
    size_t i2s_bytes_write = 0;
    uint16_t num =SAMPLE_RATE*TICK*4/1000;//882
    char *samples_data = malloc(num);

    memset(samples_data,0x00,num);
    
    for(uint16_t i =0;i<num/4;i++)
    {
        // memcpy(samples_data+4*i+1,(uint8_t *)TestAudioBlk3+count,2);
        // count +=1;
        // samples_data[4*i+1] = (uint8_t)(TestAudioBlk3[count] & 0xff);
        samples_data[4*i+2] =  (uint8_t)(TestAudioBlk3[count]>>8 & 0xff);//TestAudioBlk3[count] & 0xff00;
        
        count+=1;
    }
    // printf("%d\r\n",count);
    if(count +10 > sizeof(TestAudioBlk3))
    {
        count = 0;
    }
   
    i2s_write(I2S_NUM, samples_data, 882, &i2s_bytes_write, 100);
    // count += i2s_bytes_write; 
    free(samples_data);
}
*/
static void send_data4(void)
{
    size_t i2s_bytes_write = 0;
    uint16_t num =SAMPLE_RATE*TICK*4/1000;//882
    char *samples_data = malloc(num);
    // static char samples_data[1000] = {0};
    uint8_t a=0,b=0;
    // printf("%d\r\n",num);
    memset(samples_data,0x00,num);
    // memcpy(samples_data,TestAudioBlk0+count,num); 
    // for(uint16_t i =0;i<num/4;i++)
    // {
    //     samples_data[i*4+0]=
    //     samples_data[i*4+1]=
    //     samples_data[i*4+2]=
    //     // samples_data[i*4+3]=0x00;
    // }

    
    for(uint16_t i =0;i<num/4;i++)
    {  
        a = TestAudioBlk4[ count   ];//57
        b = TestAudioBlk4[ count + 1];//41
        // memcpy(samples_data+4*i+1,TestAudioBlk2+count,2);
        // samples_data[4*i+2] = TestAudioBlk3[count]&0x7f;
        // samples_data[4*i+3] = TestAudioBlk3[count+1]&0x7f;

        samples_data[4*i+1] =  ( TestAudioBlk4[ count+ 1] & 0x01) << 7;
        samples_data[4*i+2] = (TestAudioBlk4[ count  + 1 ]>>1) | ((TestAudioBlk4[ count ] & 0x01)<<7);//
        samples_data[4*i+3] = (TestAudioBlk4[ count ]>>1);//
        // if(a == 0x52 && b ==0x49)   
        // if(a == 0x57 && b == 0x41)   
        // {
        //     printf("%x %x %x %x\r\n",samples_data[4*i +0],samples_data[4*i +1],samples_data[4*i +2],samples_data[4*i +3]);
        // }
        count +=2;
    }
    // printf("%d\r\n",count);
    if(count +2>sizeof(TestAudioBlk4))
    {
        gpio_set_level(GPIO_OUTPUT_IO_0, 0);
        count = 0;
    }
    i2s_write(I2S_NUM, samples_data, num, &i2s_bytes_write, 100);
    // count += i2s_bytes_write; 
    free(samples_data);
}
void app_main()
{

    gpio_config_t io_conf;
    //disable interrupt
    io_conf.intr_type = GPIO_PIN_INTR_DISABLE;
    //set as output mode        
    io_conf.mode = GPIO_MODE_OUTPUT;
    //bit mask of the pins that you want to set,e.g.GPIO18/19
    io_conf.pin_bit_mask = GPIO_OUTPUT_PIN_SEL;
    //disable pull-down mode
    io_conf.pull_down_en = 0;
    //disable pull-up mode
    io_conf.pull_up_en = 0;
    //configure GPIO with the given settings
    gpio_config(&io_conf);

    //for 36Khz sample rates, we create 100Hz sine wave, every cycle need 36000/100 = 360 samples (4-bytes or 8-bytes each sample)
    //depend on bits_per_sample
    //using 6 buffers, we need 60-samples per buffer
    //if 2-channels, 16-bit each channel, total buffer is 360*4 = 1440 bytes
    //if 2-channels, 24/32-bit each channel, total buffer is 360*8 = 2880 bytes
    i2s_config_t i2s_config = {
        .mode = I2S_MODE_MASTER | I2S_MODE_TX,                                  // Only TX
        .sample_rate = SAMPLE_RATE,
        .bits_per_sample = 32,
        .channel_format = I2S_CHANNEL_FMT_RIGHT_LEFT,                           //2-channels
        .communication_format = I2S_COMM_FORMAT_I2S_MSB,//I2S_COMM_FORMAT_I2S ,| I2S_COMM_FORMAT_I2S_MSB,
        .dma_buf_count = 2,
        .dma_buf_len =128,
        .use_apll = false,
        .intr_alloc_flags = ESP_INTR_FLAG_LEVEL1                                //Interrupt level 1
    };
    i2s_pin_config_t pin_config = {
        .bck_io_num =2, //I2S_BCK_IO,
        .ws_io_num =4,// I2S_WS_IO,
        .data_out_num = 15,//I2S_DO_IO,
        .data_in_num = -1// I2S_DI_IO                                               //Not used
    };
    i2s_driver_install(I2S_NUM, &i2s_config, 0, NULL);
    i2s_set_pin(I2S_NUM, &pin_config);
    // i2s_set_adc_mode(I2S_DAC_CHANNEL_BOTH_EN);
    gpio_set_level(GPIO_OUTPUT_IO_0, 1);
    // int test_bits = 16;
    while (1) {
        // setup_triangle_sine_waves(test_bits);
        // send_data();
        // portDISABLE_INTERRUPTS();
        send_data4();
        // portENABLE_INTERRUPTS();
        vTaskDelay(5/portTICK_RATE_MS);
    
        // vTaskDelay(100/portTICK_RATE_MS);
        // printf("%d\r\n",count);
        // test_bits += 8;
        // if(test_bits > 32)
        //     test_bits = 16;

    }

}
