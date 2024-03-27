//----------------------------------------------------------------------
/**
 * @file vpr_mem_file.sv
 * @brief Defines VPR Memory file class.
 */
/*
 * Copyright (C) 2010 Verifore, Inc.
 * All rights reserved. Property of Verifore, Inc.
 * Restricted rights to use, duplicate or disclose
 * this code are granted through contract.
 */
//----------------------------------------------------------------------
`ifndef _VPR_MEM_FILE_SV_
`define _VPR_MEM_FILE_SV_
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
YkIvxY6wpEbfkkx0FiI7XCiPE7F5dCgPE0JoGEBuCouewsOUV7W8xQ8tRqdIJ7dI
6NtLi9QW6JLK/wOn4eMsbYFDyKBdbQX0zDhKWOyxFBVja/3qqPAbsV42pAoZigk8
vpZ+mMTGwKSSaAFkkMX50PLpw4iHOT3RQDdpo/EGKiWLqxJW8oEkL2mCwpGAZ7Yj
5tbsPti4YMHxS44SgSg2vhwU9hL+ldhS6OG6Elho8bKDt/7r7NSjZJg3akuoII8j
hkrG62dYm8EXSD8QMphsHqlxTRxarCyktPL+GujxV72mwnEt3M2DR82i+LsjMJL8
m0biwdHlRETs8hzRd9PGQQ==
`pragma protect data_block
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
PQnOPEAGdIYAwdg9CH7lQA==
`pragma protect end_protected

`endif // `ifndef _VPR_MEM_FILE_SV_


