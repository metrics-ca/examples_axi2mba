//----------------------------------------------------------------------
/**
 * @file crc32.v
 * @brief Defines CRC32.
 */
//----------------------------------------------------------------------

module crc32
   (
      rst_n          ,
      clk            ,
      clr            ,
      din            ,
      dout           ,
      crc            //,
   );

   //===================================================================
   // parameters
   //===================================================================

   parameter               W              =  32          ;
   parameter   [W-1:0]     INIT           =  {W{1'b1}}   ;

   //===================================================================
   // ports
   //===================================================================

   input                   rst_n          ;
   input                   clk            ;
   input                   clr            ;
   input                   din            ;
   output                  dout           ;
   output      [W-1:0]     crc            ;

`pragma protect begin_protected
`pragma protect version=1
`pragma protect encrypt_agent="dvlencrypt"
`pragma protect encrypt_agent_info="Metrics Design Automation Inc. P1735 encryptor tool"
`pragma protect author="author-a"
`pragma protect author_info="author-a-details"
`pragma protect data_method="aes256-cbc"
`pragma protect key_keyowner="Metrics Technologies Inc."
`pragma protect key_keyname="DSim"
`pragma protect key_method="rsa"
`pragma protect key_block
j9uHjdsv6q24CtedDJYSVMcUksxlF+7o/qB+w76sPcWH/uatHcxKzXDTOsyvsEFo
7sr0Ip+CIbjBHOMJDuZmekGxMYiD95h+VA8EI85E212eUtfi4r5FnZ4wJDfZq8dP
JbRxlVnOaMSHCZYeVA3TKn3mRdjCihdAgSuJSxWTsDDEzS5pOge3K0iXD5Dn4j+V
YJeJHsbK4nc03WS+jkgvSUxMEH1LBGqEZD/J1XPoEv+ir7JkSye9pxO2HMqC6KY4
XKtnkTeWwO9U5btEwGipA81+mBnpGcGU/zDmdZVoJ4TFECsxlgzsWMOkpEQyrwKk
r+/UGQygKYGE2+NKPDcpDA==
`pragma protect data_block
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
aqiYnB57u54ZaMYW/Yfy3g==
`pragma protect end_protected

endmodule
// end of file


