//----------------------------------------------------------------------
/**
 * @file vsl_msb_sfunc.sv
 * @brief Defines VSL Memory Scoreboard Standard function class.
 */
/*
 * Copyright (C) 2012 Verifore, Inc.
 * All rights reserved. Property of Verifore, Inc.
 * Restricted rights to use, duplicate or disclose
 * this code are granted through contract.
 */
//----------------------------------------------------------------------
`ifndef _VSL_MSB_SFUNC_SV_
`define _VSL_MSB_SFUNC_SV_
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
c66yvQaWQVGNPFv0pbkNut6qQFX1gbSuoAopJ89Z44tK4GucLuqbr8nPN3z0TWYM
LEf/FJdfg83h/R0qD1HMtCPqV92cCWMauK0v5DEpg1GPgU/Zeq3620EuZRzmydak
Lfj4e3U4dirwJMfat2YT9rg7mipjEpw+YJfrRRvCp11kvgiP1NUYG+OAhwoVYDcn
BczijNGihZKyvNPdItXrUWUDP+OiM4fnH/phG0flxBc/WeOkf52YfmpSdXtzZBU7
IWdm4G1ou8pPCc24qn/67rwc+Mc8BdkzgwI2ckmpvlgUxN1QQoIzFbgKHW3vyPpD
Wtsis4JgtfQYEzbkiWYb4w==
`pragma protect data_block
wGNnCnfBl1XNQ/iR6WKHWbmUgkP1Eq+yeH3pImzk3XvVYKcMCMMcw6URHjkHBoA/
jj4c41JvGagJjZ+JKLfZa/k8dk5YI5VHacjI0Nn1eK1oCq8Ys4b7K2/XG6+7kfop
ksusTXggrAglQVj/ai/sBZdUtMx6THrr0kdUrHE5Bw0y+8iV3Y466YlC9HTOzooM
JNPcWOGpvKnDoAWqehZx8UTjye+IAtxIFAbpyMUkzLtG1h32Cxm+Irn7x4BV3tuB
qObLeNQsK9Ub69YV/nue0IaOA1f8xIUImbnnq4pLISBnsi7apN/hdKyoMgC+03zs
AgU2VFaQATVZItRzwryidByo7kUgeXJMe1HvFVjqffsSJXxWBXRZfFV4/7S4oXYy
GEIF7vAv9kdSDsi0gntMUvp1xB6xIS5gHmqnNVr7phLs8xHI7KZUkcNnOa3Fi8OK
Asm6jrZWv3F9Twzhw++GTCXIAZrUOCxVyzwhiifoKO5eQBMJ3KTNDpFRqWPiO4yt
SnsUTfL+Ucbml3T3mbkBqF6yF10nK1/BmoVBoc6s1p2OkHkBaLEjFC/U/fbxHLk7
OPGfPdPVi+cnWV0FuZNj6rvkF1bf1k17449yBm80daaLZ5gs30PJSC3d3uD7fKBL
/w4QG99dG0iFumw+7Yw3Q31UcXUdbZIwIdDT/gLiJvuCJfcc7Yrzfyeuj7RDPvj5
taHf7mm85G3ZEjE0foW80UMa2A8ewbOvmdF2VHz6GFgUd3x5lDQZtCriSG+ZAnGT
FxeHB/JiBqVRs+UM+FPlBnpexQqimmggR/tDRM8N8WFACMcWlu1sA07wBCX/ser4
gKnx4fkcLDqsc6Hv4hBbn4fk7ALC5A2R40jEulpSFDnBpj4HxkR90kbWZWnuM0oZ
3QGgrZ7kM9OPEeLI/QIxOxwXqlHTfWO/VS1XIuhpCnyN4REMliyZXtfQH1okod9E
8tb62wzuodLpqinbbnhsW2by6gWGRXDXt8jwCxkKiAU01MFlK0xDwsOdcV1iBYYq
BdWQxggoXz4LDP+atoSf6xe0XjV3Bp8bsgMU1AvHVt7e3qso3IhklbAq1uYOrG+K
90lNc9wFRavE48AGWKgSeHXyg06ko0mfY2bZTJMMvzAcMgsmuLqQG3+/nv04X6ug
HDyiWlLBQjPXlHsBTX16yuA+bTk8tb9hcsHVjZ/5BkmEHJOfcFu29liQ3Q80NKA9
y/jDmvvIbS6fV831Ov0aKQoKE7yXJed7XSbeNs9ToGLy6nVQ+WFwfHMmKcLpjUOk
R9npYlxK8rDq7aR3SU2LYqy/u2pxTF1QyH9/mzo9sRsoQhdIroqrqyYOKBcB02CE
IwwR/1umQoTUQifr7pD5txDrxxj77KgS1nXZyeWpAoSvALxFY7PGytMesqTL6m36
TDyX9krwq3KDHM+YaEcqk6q4T35iuXJNaAWjNnqD1QvtClfzWNDCbnwFzWYY9vhV
8T7BaSFZNGLtBb0OETyCWxdgR3N9DLFhqm+ufNSliJZr0N34oXkFYsLHoFKbZDSL
oZbHkk4zkA6sEZIB0KQ425UH5CSkK7dXoGy5cLYzWLx2LzOxpoQGjRzlNQJryLfe
6NzbwiRsj1NBw3x9cM1jjlTf5RQSXlDoDtrmGHRvlgDTWthGaTlnpgwESwzEu8QG
InpU8R81WonfclhiNYFVY975MNFwTmUAfaHIlBt/dKraMXHlbux6nA4fLJTy9ous
sIMuCEXj14xFI9OHBwZDVQWf0HjYYi8AVihZetO4Yqk1uk1VmyKL4g69b6kv3lYS
R+7I0vpEklyR4FHBEO2eQ9QVRxw4jTcmFKtpji3is/CkWsCkc/45Y19CBwADJ36w
vsovUqUrd42gBy+YSj45Ys8RqWNOiWz+ljOiFC0J9v8lnvM1Nep1YUqpMFtckFKv
asJKyOWdcmuF0sLxq0KLdk5YOhtaMbA95W4Smn6f+2M=
`pragma protect end_protected

`endif // `ifndef _VSL_MSB_SFUNC_SV_


