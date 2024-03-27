//----------------------------------------------------------------------
/**
 * @file vf_hndlr_log.sv
 * @brief Defines VF handler log class.
 */
/*
 * Copyright (C) 2009 Verifore, Inc.
 * All rights reserved. Property of Verifore, Inc.
 * Restricted rights to use, duplicate or disclose
 * this code are granted through contract.
 */
//----------------------------------------------------------------------
`ifndef _VF_HNDLR_LOG_SV_
`define _VF_HNDLR_LOG_SV_
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
C6LZbOZzs1UGckhj46U//Y/kNzjaHgsSteSGuHVT28qWSQSvsWf4gQjkUxSsL24s
7IZMguZapSptHCvV0pju5FMKgJUP0IK9KUmO76M7OjBmjwvktyi8Ness6nQ9K3XX
GfxpN0geQTrxevustr/Ere2g128mNJqmho6Eonp37fUkgXOCJ8YUrVpWwjpj69Op
Lg3M/Nv8ng8I6aaLNQsjuZzQxZHXzfsV3QroUJKpnNZS4MkePQz0ETeZKEJ08yA6
2UgWvyJs5U2ZIhooEOmsO4J5P7dMaKZGFnMVQu1rv2FvzaR5ds7Xhfjp5BL7QnQj
Gx42c5kkQ9fdhwvYdwt6cw==
`pragma protect data_block
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
`pragma protect end_protected

`endif // `ifndef _VF_HNDLR_LOG_SV_



