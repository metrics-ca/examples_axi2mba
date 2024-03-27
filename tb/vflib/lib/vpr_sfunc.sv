//----------------------------------------------------------------------
/**
 * @file vpr_sfunc.sv
 * @brief Defines Standard function class.
 */
/*
 * Copyright (C) 2007-2009 Verifore, Inc.
 * All rights reserved. Property of Verifore, Inc.
 * Restricted rights to use, duplicate or disclose
 * this code are granted through contract.
 */
//----------------------------------------------------------------------
`ifndef _VPR_SFUNC_SV_
`define _VPR_SFUNC_SV_
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
YA23mLNMLZ2KDJMoxxhgup0yHSItxTZPuBvJdmbZhXw8XDtpvitWBkcUnsYaSOnr
OG4jrg8ffu8ZUF4Iteo7GLa0jgShtSW458NpVgyFWQPIAHlllPUI63f2ahLUSzYj
AsK+02bBAUgCaK0FHfV3bKszevkrdB3XzD02Mb6laOXWCtDGI6v8sh+CAB9zfcFk
dLV9NYcaWGJH3uRaYVXVoi53QZjHX3e2faUOA/5II2D5Pjh9Iu8AshRln97QcnQ4
jTviHeFHgEgtWRwvpCjPbUNbv7MtBrDKXgkPBR7+wC72Tpy3pC3QLr/L37128ydx
Vi6IGJ8ABra6n2L1B33MiA==
`pragma protect data_block
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
`pragma protect end_protected

`endif // `ifndef _VPR_SFUNC_SV_


