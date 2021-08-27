//FIFO means first in first out. Which data comes in first will be written first
//and go out first. Scynchronous fifo which only have one clock deals with write or read function
`define WIDTH 16//declare the data width
`define SIZE_BITS 5//5 bits counter meas there are 32 address which can save data
`define SIZE(1<<`SIZE_BITS)//1<<`SIZE_BITS also means 2^`SIZE_BITS
                           //equal to 2^5 = 32

module sync_fifo(
  input logic reset,
  input logic clk,
  input logic write,//write enable
  input logic read,//read enable
  input logic [`WIDTH-1:0] data_in,
  output logic [`WIDTH-1:0] data_out,
  output logic empty,
  output logic full,
  output logic [`SIZE_BITS-1:0] counter
  );

//pointers will decide where data should go in or come out
logic [`SIZE_BITS-1:0] write_pointer;
logic [`SIZE_BITS-1:0] read_pointer;

//array
logic [`WIDTH-1:0] fifo_mem [`SIZE-1:0];

//make sure FIFO doesn't overwrite or underread
always @(counter) begin
  empty = (counter = 0);
  full  = (counter = `SIZE);
  
end

//declare counter location which decide the address to be written or read 
always @(posedge clk or posedge reset) begin
  if (reset)
  counter <= 0;
  //avoid read and write at the same time
  else if(!full && write) && (!empty && read)
    counter <= counter;
  //write data only
  else if(!full && write)
    counter <= counter +1;
  //read data only
  else if(!empty && read)
    counter <= counter -1;
  //counter isn't changed
  else 
    counter <= counter;
end

//declare data_in function just likes normal memory
always @(posedge clk) begin//don't need to declare reset bc it doesn't matter about output
  if(!full && write)
    fifo_mem[write_pointer] <= data_in;
  else
    fifo_mem[write_pointer] <= fifo_mem[write_pointer];
end

//declare data_out function just like normal memory
always @(posedge clk or posedge reset) begin
  if(reset)
    data_out <= 0;
  else
  begin
    if(!empty && read)
    data_out <= fifo_mem[read_pointer];
    else
    data_out <= data_out;
  end
  
end

//declare the function of pointers 
always @(posedge clk or posedge reset) begin
  if(reset)
   begin 
     write_pointer <= 0;
     read_pointer  <= 0;
   end
   else 
   begin
      if(!full && write)
        write_pointer <= write_pointer +1;
      else
        write_pointer <= write_pointer;
   
      if(!empty && read)
        read_pointer <= read_pointer +1;
      else
        read_pointer <= read_pointer;
   end 
end
endmodule