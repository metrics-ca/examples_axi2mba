//----------------------------------------------------------------------
/**
 * @file vpr_math.sv
 * @brief Defines VPR Math library abstract class.
 */
/*
 * Copyright (C) 2009-2011 Verifore, Inc.
 * All rights reserved. Property of Verifore, Inc.
 * Restricted rights to use, duplicate or disclose
 * this code are granted through contract.
 */
//----------------------------------------------------------------------
`ifndef _VPR_MATH_SV_
`define _VPR_MATH_SV_
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
Q3ZWJTuBZxUwe58h+L3xShCIr+Jdd25+SBK+sP8+eCPdldevPE3OMQmFM1rOo8Yp
MRY8JBkShmwkBXfdB/HXXoO4ppbTi0fJZLFoN26NfepyAwcy5CtLeGPWfAZ8uqW0
g6T71GKBSrLq0tLGi3vnN2xKhJcm6WAbJReiiHTZGM+w5W/13/qiVU71yl2pOBKT
t6T8Sb3VYWGMsjHJNLvJAX+G+z5rJAZuNS6yFXwwm/JJPMgKR5szkEWFKWuKG8ES
PC3cj75zy2TGImfPYBVbb01iMaUaiX2KfRvCWPNGVqMwrCdnS3QyV14Q7BtC26Gd
cQEdhqmT2uY3iuCJQ22STw==
`pragma protect data_block
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
qoTjKB1IHKzuXLhE51aYmw==
`pragma protect end_protected

`endif // `ifndef _VPR_MATH_SV_


