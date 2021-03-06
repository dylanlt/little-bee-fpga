module VGAMod
(
    input                   CLK,
    input                   nRST,

    input                   PixelClk,

    output                  LCD_DE,
    output                  LCD_HSYNC,
    output                  LCD_VSYNC,

	output          [4:0]   LCD_B,
	output          [5:0]   LCD_G,
	output          [4:0]   LCD_R
);

    reg         [15:0]  PixelCount;
    reg         [15:0]  LineCount;

	//pluse include in back pluse; t=pluse, sync act; t=bp, data act; t=bp+height, data end

// 480x272
	localparam      V_BackPorch = 16'd12; 
	localparam      V_Pluse 	= 16'd11; 
	localparam      HeightPixel = 16'd272;
	localparam      V_FrontPorch= 16'd8; 
	
	localparam      H_BackPorch = 16'd50; 
	localparam      H_Pluse 	= 16'd10; 
	localparam      WidthPixel  = 16'd480;
	localparam      H_FrontPorch= 16'd8;

// 800x480
	/*localparam      V_BackPorch = 16'd0; //6
	localparam      V_Pluse 	= 16'd5; 
	localparam      HightPixel  = 16'd480;
	localparam      V_FrontPorch= 16'd45; //62

	localparam      H_BackPorch = 16'd182; 	//NOTE: 高像素时钟时，增加这里的延迟，方便K210加入中断
	localparam      H_Pluse 	= 16'd1; 
	localparam      WidthPixel  = 16'd800;
	localparam      H_FrontPorch= 16'd210;*/

    localparam      PixelForHS  =   WidthPixel  + H_BackPorch + H_FrontPorch;  	
    localparam      LineForVS   =   HeightPixel + V_BackPorch + V_FrontPorch;

    always @(  posedge PixelClk or negedge nRST  )begin
        if( !nRST ) begin
            LineCount       <=  16'b0;    
            PixelCount      <=  16'b0;
            end
        else if(  PixelCount  ==  PixelForHS ) begin
            PixelCount      <=  16'b0;
            LineCount       <=  LineCount + 1'b1;
            end
        else if(  LineCount  == LineForVS  ) begin
            LineCount       <=  16'b0;
            PixelCount      <=  16'b0;
            end
        else
            PixelCount      <=  PixelCount + 1'b1;
    end

	reg			[9:0]  Data_R;
	reg			[9:0]  Data_G;
	reg			[9:0]  Data_B;

    always @(  posedge PixelClk or negedge nRST  )begin
        if( !nRST ) begin
			Data_R <= 9'b0;
			Data_G <= 9'b0;
			Data_B <= 9'b0;
            end
        else begin
			end
	end

	//注意这里HSYNC和VSYNC负极性
    assign  LCD_HSYNC = (( PixelCount >= H_Pluse)&&( PixelCount <= (PixelForHS-H_FrontPorch))) ? 1'b0 : 1'b1;
    //assign  LCD_VSYNC = ((( LineCount  >= 0 )&&( LineCount  <= (V_Pluse-1) )) ) ? 1'b1 : 1'b0;		//这里不减一的话，图片底部会往下拖尾？
	assign  LCD_VSYNC = ((( LineCount  >= V_Pluse )&&( LineCount  <= (LineForVS-0) )) ) ? 1'b0 : 1'b1;
    //assign  FIFO_RST  = (( PixelCount ==0)) ? 1'b1 : 1'b0;  //留给主机H_BackPorch的时间进入中断，发送数据

    assign  LCD_DE = (  ( PixelCount >= H_BackPorch )&&
                        ( PixelCount <= PixelForHS-H_FrontPorch ) &&
                        ( LineCount >= V_BackPorch ) &&
                        ( LineCount <= LineForVS-V_FrontPorch-1 ))  ? 1'b1 : 1'b0;
						//这里不减一，会抖动

    assign  LCD_R   =   (PixelCount<040)? 5'b00000 : 
                        (PixelCount<080 ? 5'b00100 :    
                        (PixelCount<120 ? 5'b01000 :    
                        (PixelCount<160 ? 5'b10000 :  5'b00000 )));

    assign  LCD_G   =   (PixelCount<200)? 6'b000000 : 
                        (PixelCount<240 ? 6'b001000 :    
                        (PixelCount<280 ? 6'b010000 :  
                        (PixelCount<320 ? 6'b100000 : 6'b000000 )));

    assign  LCD_B   =   (PixelCount<360)? 5'b00000 : 
                        (PixelCount<400 ? 5'b00100 :    
                        (PixelCount<440 ? 5'b01000 :    
                        (PixelCount<480 ? 5'b10000 :  5'b00000 )));

endmodule
