//----------------------------------------------------------------------
/**
 * @file vf_addr_range.sv
 * @brief Defines VF address range class.
 */
/*
 * Copyright (C) 2009-2011 Verifore, Inc.
 * All rights reserved. Property of Verifore, Inc.
 * Restricted rights to use, duplicate or disclose
 * this code are granted through contract.
 */
//----------------------------------------------------------------------
`ifndef _VF_ADDR_RANGE_SV_
`define _VF_ADDR_RANGE_SV_
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
CWucKGYZYOsiCrs9se/O6NGMB4VUblblo2nkANopT1bkVo+dCN7ztmeZwKbuBYDZ
cmSekCZ+b2+V8tCqurmvjOm+pojD/aiLXCQKXqmMd3GexUXrDS1gvQuWGAAjftFf
odCLjTwb4UJPu7yZ62sO5yD9B/28zbQrvbYUzR9HK2D7JL8DIywFGK7DVlwrYRoU
cPVyOlFaWatxD1b3tQwfDbep1HUXZyxgDycN2W3xnJAYrv0pcId2YIl6h2Ayrio3
ZlQDvMi0CdZIda2KqAiK2zcslQjLx8jp8UMU+aSdisC+RMJlOMOffHqcL1Gf7fbb
sKRP06uEc+i20Ef6O+cZaA==
`pragma protect data_block
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
QWNy4ifZ/yJBoRSlUQBGkA==
`pragma protect end_protected

`endif // `ifndef _VF_ADDR_RANGE_SV_

