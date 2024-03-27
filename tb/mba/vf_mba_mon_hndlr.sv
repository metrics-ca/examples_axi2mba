//----------------------------------------------------------------------
/**
 * @file vf_mba_mon_hndlr.sv
 * @brief Defines VF MBA monitor interface handler class.
 */
/*
 * Copyright (C) 2009-2016 Verifore, Inc.
 * All rights reserved. Property of Verifore, Inc.
 * Restricted rights to use, duplicate or disclose
 * this code are granted through contract.
 */
//----------------------------------------------------------------------
`ifndef _VF_MBA_MON_HNDLR_SV_
`define _VF_MBA_MON_HNDLR_SV_
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
SOGr9Vtga8nLDVml5u8CG3azVJ3ByGvYzW27fjCSKExSI+uyQbDZTtTs9jwt8Ivy
3+dHxx6DcCkRgapWD2NAvw8MW29n0eJoPyqNsq6ICXZd79oo9gU00cW8++p1p+7F
GrG19VzylWRnqpV0empiibvaR6vTMFbWxYfJEFMwaW/zu/7lixzvmHqW3Fd4dk6a
WJoccI1UdUWcG0BPEtCsFKdWMsH7QKh7qgTCgp0t8N31xdow57j67QocdD5vJm7I
0piN9EFcYGekpdd1ozip3lk4krMlbNMCUnzCI3LI2xqNfAjlDjqzGH30KUaiQe8b
Vq3PHZPzT0n1EiNUFjObOw==
`pragma protect data_block
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
`pragma protect end_protected

`endif // `ifndef _VF_MBA_MON_HNDLR_SV_


