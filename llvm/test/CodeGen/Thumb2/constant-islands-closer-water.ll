; RUN: llc -mtriple=thumbv7-linux-gnueabihf %s -o - | FileCheck %s

; Each case of the switch materializes the address of a distinct 16 byte
; constant with an adr (t2LEApcrel, range +-4095), and the constants in
; total are larger than that range, so they need to be spread out between
; the case blocks. Placing each constant as far away as possible keeps
; pushing previously placed constants out of range again. Once the pass
; falls back to placing constants in water closer to the user, it must
; pick the closest water even if it requires more alignment padding;
; otherwise the pass failed to converge.

; CHECK-LABEL: many_constants:
; CHECK:       tbh
; CHECK:       adr r{{[0-9]+}}, .LCPI0_

declare void @use(ptr)

define void @many_constants(i32 %x) {
entry:
  %p = alloca <2 x i64>, align 8
  switch i32 %x, label %exit [
    i32 0, label %bb0
    i32 1, label %bb1
    i32 2, label %bb2
    i32 3, label %bb3
    i32 4, label %bb4
    i32 5, label %bb5
    i32 6, label %bb6
    i32 7, label %bb7
    i32 8, label %bb8
    i32 9, label %bb9
    i32 10, label %bb10
    i32 11, label %bb11
    i32 12, label %bb12
    i32 13, label %bb13
    i32 14, label %bb14
    i32 15, label %bb15
    i32 16, label %bb16
    i32 17, label %bb17
    i32 18, label %bb18
    i32 19, label %bb19
    i32 20, label %bb20
    i32 21, label %bb21
    i32 22, label %bb22
    i32 23, label %bb23
    i32 24, label %bb24
    i32 25, label %bb25
    i32 26, label %bb26
    i32 27, label %bb27
    i32 28, label %bb28
    i32 29, label %bb29
    i32 30, label %bb30
    i32 31, label %bb31
    i32 32, label %bb32
    i32 33, label %bb33
    i32 34, label %bb34
    i32 35, label %bb35
    i32 36, label %bb36
    i32 37, label %bb37
    i32 38, label %bb38
    i32 39, label %bb39
    i32 40, label %bb40
    i32 41, label %bb41
    i32 42, label %bb42
    i32 43, label %bb43
    i32 44, label %bb44
    i32 45, label %bb45
    i32 46, label %bb46
    i32 47, label %bb47
    i32 48, label %bb48
    i32 49, label %bb49
    i32 50, label %bb50
    i32 51, label %bb51
    i32 52, label %bb52
    i32 53, label %bb53
    i32 54, label %bb54
    i32 55, label %bb55
    i32 56, label %bb56
    i32 57, label %bb57
    i32 58, label %bb58
    i32 59, label %bb59
    i32 60, label %bb60
    i32 61, label %bb61
    i32 62, label %bb62
    i32 63, label %bb63
    i32 64, label %bb64
    i32 65, label %bb65
    i32 66, label %bb66
    i32 67, label %bb67
    i32 68, label %bb68
    i32 69, label %bb69
    i32 70, label %bb70
    i32 71, label %bb71
    i32 72, label %bb72
    i32 73, label %bb73
    i32 74, label %bb74
    i32 75, label %bb75
    i32 76, label %bb76
    i32 77, label %bb77
    i32 78, label %bb78
    i32 79, label %bb79
    i32 80, label %bb80
    i32 81, label %bb81
    i32 82, label %bb82
    i32 83, label %bb83
    i32 84, label %bb84
    i32 85, label %bb85
    i32 86, label %bb86
    i32 87, label %bb87
    i32 88, label %bb88
    i32 89, label %bb89
    i32 90, label %bb90
    i32 91, label %bb91
    i32 92, label %bb92
    i32 93, label %bb93
    i32 94, label %bb94
    i32 95, label %bb95
    i32 96, label %bb96
    i32 97, label %bb97
    i32 98, label %bb98
    i32 99, label %bb99
    i32 100, label %bb100
    i32 101, label %bb101
    i32 102, label %bb102
    i32 103, label %bb103
    i32 104, label %bb104
    i32 105, label %bb105
    i32 106, label %bb106
    i32 107, label %bb107
    i32 108, label %bb108
    i32 109, label %bb109
    i32 110, label %bb110
    i32 111, label %bb111
    i32 112, label %bb112
    i32 113, label %bb113
    i32 114, label %bb114
    i32 115, label %bb115
    i32 116, label %bb116
    i32 117, label %bb117
    i32 118, label %bb118
    i32 119, label %bb119
    i32 120, label %bb120
    i32 121, label %bb121
    i32 122, label %bb122
    i32 123, label %bb123
    i32 124, label %bb124
    i32 125, label %bb125
    i32 126, label %bb126
    i32 127, label %bb127
    i32 128, label %bb128
    i32 129, label %bb129
    i32 130, label %bb130
    i32 131, label %bb131
    i32 132, label %bb132
    i32 133, label %bb133
    i32 134, label %bb134
    i32 135, label %bb135
    i32 136, label %bb136
    i32 137, label %bb137
    i32 138, label %bb138
    i32 139, label %bb139
    i32 140, label %bb140
    i32 141, label %bb141
    i32 142, label %bb142
    i32 143, label %bb143
    i32 144, label %bb144
    i32 145, label %bb145
    i32 146, label %bb146
    i32 147, label %bb147
    i32 148, label %bb148
    i32 149, label %bb149
    i32 150, label %bb150
    i32 151, label %bb151
    i32 152, label %bb152
    i32 153, label %bb153
    i32 154, label %bb154
    i32 155, label %bb155
    i32 156, label %bb156
    i32 157, label %bb157
    i32 158, label %bb158
    i32 159, label %bb159
    i32 160, label %bb160
    i32 161, label %bb161
    i32 162, label %bb162
    i32 163, label %bb163
    i32 164, label %bb164
    i32 165, label %bb165
    i32 166, label %bb166
    i32 167, label %bb167
    i32 168, label %bb168
    i32 169, label %bb169
    i32 170, label %bb170
    i32 171, label %bb171
    i32 172, label %bb172
    i32 173, label %bb173
    i32 174, label %bb174
    i32 175, label %bb175
    i32 176, label %bb176
    i32 177, label %bb177
    i32 178, label %bb178
    i32 179, label %bb179
    i32 180, label %bb180
    i32 181, label %bb181
    i32 182, label %bb182
    i32 183, label %bb183
    i32 184, label %bb184
    i32 185, label %bb185
    i32 186, label %bb186
    i32 187, label %bb187
    i32 188, label %bb188
    i32 189, label %bb189
    i32 190, label %bb190
    i32 191, label %bb191
    i32 192, label %bb192
    i32 193, label %bb193
    i32 194, label %bb194
    i32 195, label %bb195
    i32 196, label %bb196
    i32 197, label %bb197
    i32 198, label %bb198
    i32 199, label %bb199
    i32 200, label %bb200
    i32 201, label %bb201
    i32 202, label %bb202
    i32 203, label %bb203
    i32 204, label %bb204
    i32 205, label %bb205
    i32 206, label %bb206
    i32 207, label %bb207
    i32 208, label %bb208
    i32 209, label %bb209
    i32 210, label %bb210
    i32 211, label %bb211
    i32 212, label %bb212
    i32 213, label %bb213
    i32 214, label %bb214
    i32 215, label %bb215
    i32 216, label %bb216
    i32 217, label %bb217
    i32 218, label %bb218
    i32 219, label %bb219
    i32 220, label %bb220
    i32 221, label %bb221
    i32 222, label %bb222
    i32 223, label %bb223
    i32 224, label %bb224
    i32 225, label %bb225
    i32 226, label %bb226
    i32 227, label %bb227
    i32 228, label %bb228
    i32 229, label %bb229
    i32 230, label %bb230
    i32 231, label %bb231
    i32 232, label %bb232
    i32 233, label %bb233
    i32 234, label %bb234
    i32 235, label %bb235
    i32 236, label %bb236
    i32 237, label %bb237
    i32 238, label %bb238
    i32 239, label %bb239
    i32 240, label %bb240
    i32 241, label %bb241
    i32 242, label %bb242
    i32 243, label %bb243
    i32 244, label %bb244
    i32 245, label %bb245
    i32 246, label %bb246
    i32 247, label %bb247
    i32 248, label %bb248
    i32 249, label %bb249
    i32 250, label %bb250
    i32 251, label %bb251
    i32 252, label %bb252
    i32 253, label %bb253
    i32 254, label %bb254
    i32 255, label %bb255
    i32 256, label %bb256
    i32 257, label %bb257
    i32 258, label %bb258
    i32 259, label %bb259
    i32 260, label %bb260
    i32 261, label %bb261
    i32 262, label %bb262
    i32 263, label %bb263
    i32 264, label %bb264
    i32 265, label %bb265
    i32 266, label %bb266
    i32 267, label %bb267
    i32 268, label %bb268
    i32 269, label %bb269
    i32 270, label %bb270
    i32 271, label %bb271
    i32 272, label %bb272
    i32 273, label %bb273
    i32 274, label %bb274
    i32 275, label %bb275
    i32 276, label %bb276
    i32 277, label %bb277
    i32 278, label %bb278
    i32 279, label %bb279
    i32 280, label %bb280
    i32 281, label %bb281
    i32 282, label %bb282
    i32 283, label %bb283
    i32 284, label %bb284
    i32 285, label %bb285
    i32 286, label %bb286
    i32 287, label %bb287
    i32 288, label %bb288
    i32 289, label %bb289
    i32 290, label %bb290
    i32 291, label %bb291
    i32 292, label %bb292
    i32 293, label %bb293
    i32 294, label %bb294
    i32 295, label %bb295
    i32 296, label %bb296
    i32 297, label %bb297
    i32 298, label %bb298
    i32 299, label %bb299
  ]

bb0:
  store <2 x i64> <i64 1, i64 1000>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb1:
  store <2 x i64> <i64 1, i64 1001>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb2:
  store <2 x i64> <i64 1, i64 1002>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb3:
  store <2 x i64> <i64 1, i64 1003>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb4:
  store <2 x i64> <i64 1, i64 1004>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb5:
  store <2 x i64> <i64 1, i64 1005>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb6:
  store <2 x i64> <i64 1, i64 1006>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb7:
  store <2 x i64> <i64 1, i64 1007>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb8:
  store <2 x i64> <i64 1, i64 1008>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb9:
  store <2 x i64> <i64 1, i64 1009>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb10:
  store <2 x i64> <i64 1, i64 1010>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb11:
  store <2 x i64> <i64 1, i64 1011>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb12:
  store <2 x i64> <i64 1, i64 1012>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb13:
  store <2 x i64> <i64 1, i64 1013>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb14:
  store <2 x i64> <i64 1, i64 1014>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb15:
  store <2 x i64> <i64 1, i64 1015>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb16:
  store <2 x i64> <i64 1, i64 1016>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb17:
  store <2 x i64> <i64 1, i64 1017>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb18:
  store <2 x i64> <i64 1, i64 1018>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb19:
  store <2 x i64> <i64 1, i64 1019>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb20:
  store <2 x i64> <i64 1, i64 1020>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb21:
  store <2 x i64> <i64 1, i64 1021>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb22:
  store <2 x i64> <i64 1, i64 1022>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb23:
  store <2 x i64> <i64 1, i64 1023>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb24:
  store <2 x i64> <i64 1, i64 1024>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb25:
  store <2 x i64> <i64 1, i64 1025>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb26:
  store <2 x i64> <i64 1, i64 1026>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb27:
  store <2 x i64> <i64 1, i64 1027>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb28:
  store <2 x i64> <i64 1, i64 1028>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb29:
  store <2 x i64> <i64 1, i64 1029>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb30:
  store <2 x i64> <i64 1, i64 1030>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb31:
  store <2 x i64> <i64 1, i64 1031>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb32:
  store <2 x i64> <i64 1, i64 1032>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb33:
  store <2 x i64> <i64 1, i64 1033>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb34:
  store <2 x i64> <i64 1, i64 1034>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb35:
  store <2 x i64> <i64 1, i64 1035>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb36:
  store <2 x i64> <i64 1, i64 1036>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb37:
  store <2 x i64> <i64 1, i64 1037>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb38:
  store <2 x i64> <i64 1, i64 1038>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb39:
  store <2 x i64> <i64 1, i64 1039>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb40:
  store <2 x i64> <i64 1, i64 1040>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb41:
  store <2 x i64> <i64 1, i64 1041>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb42:
  store <2 x i64> <i64 1, i64 1042>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb43:
  store <2 x i64> <i64 1, i64 1043>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb44:
  store <2 x i64> <i64 1, i64 1044>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb45:
  store <2 x i64> <i64 1, i64 1045>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb46:
  store <2 x i64> <i64 1, i64 1046>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb47:
  store <2 x i64> <i64 1, i64 1047>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb48:
  store <2 x i64> <i64 1, i64 1048>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb49:
  store <2 x i64> <i64 1, i64 1049>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb50:
  store <2 x i64> <i64 1, i64 1050>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb51:
  store <2 x i64> <i64 1, i64 1051>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb52:
  store <2 x i64> <i64 1, i64 1052>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb53:
  store <2 x i64> <i64 1, i64 1053>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb54:
  store <2 x i64> <i64 1, i64 1054>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb55:
  store <2 x i64> <i64 1, i64 1055>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb56:
  store <2 x i64> <i64 1, i64 1056>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb57:
  store <2 x i64> <i64 1, i64 1057>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb58:
  store <2 x i64> <i64 1, i64 1058>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb59:
  store <2 x i64> <i64 1, i64 1059>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb60:
  store <2 x i64> <i64 1, i64 1060>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb61:
  store <2 x i64> <i64 1, i64 1061>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb62:
  store <2 x i64> <i64 1, i64 1062>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb63:
  store <2 x i64> <i64 1, i64 1063>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb64:
  store <2 x i64> <i64 1, i64 1064>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb65:
  store <2 x i64> <i64 1, i64 1065>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb66:
  store <2 x i64> <i64 1, i64 1066>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb67:
  store <2 x i64> <i64 1, i64 1067>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb68:
  store <2 x i64> <i64 1, i64 1068>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb69:
  store <2 x i64> <i64 1, i64 1069>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb70:
  store <2 x i64> <i64 1, i64 1070>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb71:
  store <2 x i64> <i64 1, i64 1071>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb72:
  store <2 x i64> <i64 1, i64 1072>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb73:
  store <2 x i64> <i64 1, i64 1073>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb74:
  store <2 x i64> <i64 1, i64 1074>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb75:
  store <2 x i64> <i64 1, i64 1075>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb76:
  store <2 x i64> <i64 1, i64 1076>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb77:
  store <2 x i64> <i64 1, i64 1077>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb78:
  store <2 x i64> <i64 1, i64 1078>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb79:
  store <2 x i64> <i64 1, i64 1079>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb80:
  store <2 x i64> <i64 1, i64 1080>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb81:
  store <2 x i64> <i64 1, i64 1081>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb82:
  store <2 x i64> <i64 1, i64 1082>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb83:
  store <2 x i64> <i64 1, i64 1083>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb84:
  store <2 x i64> <i64 1, i64 1084>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb85:
  store <2 x i64> <i64 1, i64 1085>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb86:
  store <2 x i64> <i64 1, i64 1086>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb87:
  store <2 x i64> <i64 1, i64 1087>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb88:
  store <2 x i64> <i64 1, i64 1088>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb89:
  store <2 x i64> <i64 1, i64 1089>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb90:
  store <2 x i64> <i64 1, i64 1090>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb91:
  store <2 x i64> <i64 1, i64 1091>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb92:
  store <2 x i64> <i64 1, i64 1092>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb93:
  store <2 x i64> <i64 1, i64 1093>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb94:
  store <2 x i64> <i64 1, i64 1094>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb95:
  store <2 x i64> <i64 1, i64 1095>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb96:
  store <2 x i64> <i64 1, i64 1096>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb97:
  store <2 x i64> <i64 1, i64 1097>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb98:
  store <2 x i64> <i64 1, i64 1098>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb99:
  store <2 x i64> <i64 1, i64 1099>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb100:
  store <2 x i64> <i64 1, i64 1100>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb101:
  store <2 x i64> <i64 1, i64 1101>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb102:
  store <2 x i64> <i64 1, i64 1102>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb103:
  store <2 x i64> <i64 1, i64 1103>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb104:
  store <2 x i64> <i64 1, i64 1104>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb105:
  store <2 x i64> <i64 1, i64 1105>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb106:
  store <2 x i64> <i64 1, i64 1106>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb107:
  store <2 x i64> <i64 1, i64 1107>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb108:
  store <2 x i64> <i64 1, i64 1108>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb109:
  store <2 x i64> <i64 1, i64 1109>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb110:
  store <2 x i64> <i64 1, i64 1110>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb111:
  store <2 x i64> <i64 1, i64 1111>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb112:
  store <2 x i64> <i64 1, i64 1112>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb113:
  store <2 x i64> <i64 1, i64 1113>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb114:
  store <2 x i64> <i64 1, i64 1114>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb115:
  store <2 x i64> <i64 1, i64 1115>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb116:
  store <2 x i64> <i64 1, i64 1116>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb117:
  store <2 x i64> <i64 1, i64 1117>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb118:
  store <2 x i64> <i64 1, i64 1118>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb119:
  store <2 x i64> <i64 1, i64 1119>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb120:
  store <2 x i64> <i64 1, i64 1120>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb121:
  store <2 x i64> <i64 1, i64 1121>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb122:
  store <2 x i64> <i64 1, i64 1122>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb123:
  store <2 x i64> <i64 1, i64 1123>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb124:
  store <2 x i64> <i64 1, i64 1124>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb125:
  store <2 x i64> <i64 1, i64 1125>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb126:
  store <2 x i64> <i64 1, i64 1126>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb127:
  store <2 x i64> <i64 1, i64 1127>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb128:
  store <2 x i64> <i64 1, i64 1128>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb129:
  store <2 x i64> <i64 1, i64 1129>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb130:
  store <2 x i64> <i64 1, i64 1130>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb131:
  store <2 x i64> <i64 1, i64 1131>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb132:
  store <2 x i64> <i64 1, i64 1132>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb133:
  store <2 x i64> <i64 1, i64 1133>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb134:
  store <2 x i64> <i64 1, i64 1134>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb135:
  store <2 x i64> <i64 1, i64 1135>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb136:
  store <2 x i64> <i64 1, i64 1136>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb137:
  store <2 x i64> <i64 1, i64 1137>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb138:
  store <2 x i64> <i64 1, i64 1138>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb139:
  store <2 x i64> <i64 1, i64 1139>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb140:
  store <2 x i64> <i64 1, i64 1140>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb141:
  store <2 x i64> <i64 1, i64 1141>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb142:
  store <2 x i64> <i64 1, i64 1142>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb143:
  store <2 x i64> <i64 1, i64 1143>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb144:
  store <2 x i64> <i64 1, i64 1144>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb145:
  store <2 x i64> <i64 1, i64 1145>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb146:
  store <2 x i64> <i64 1, i64 1146>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb147:
  store <2 x i64> <i64 1, i64 1147>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb148:
  store <2 x i64> <i64 1, i64 1148>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb149:
  store <2 x i64> <i64 1, i64 1149>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb150:
  store <2 x i64> <i64 1, i64 1150>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb151:
  store <2 x i64> <i64 1, i64 1151>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb152:
  store <2 x i64> <i64 1, i64 1152>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb153:
  store <2 x i64> <i64 1, i64 1153>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb154:
  store <2 x i64> <i64 1, i64 1154>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb155:
  store <2 x i64> <i64 1, i64 1155>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb156:
  store <2 x i64> <i64 1, i64 1156>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb157:
  store <2 x i64> <i64 1, i64 1157>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb158:
  store <2 x i64> <i64 1, i64 1158>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb159:
  store <2 x i64> <i64 1, i64 1159>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb160:
  store <2 x i64> <i64 1, i64 1160>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb161:
  store <2 x i64> <i64 1, i64 1161>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb162:
  store <2 x i64> <i64 1, i64 1162>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb163:
  store <2 x i64> <i64 1, i64 1163>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb164:
  store <2 x i64> <i64 1, i64 1164>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb165:
  store <2 x i64> <i64 1, i64 1165>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb166:
  store <2 x i64> <i64 1, i64 1166>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb167:
  store <2 x i64> <i64 1, i64 1167>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb168:
  store <2 x i64> <i64 1, i64 1168>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb169:
  store <2 x i64> <i64 1, i64 1169>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb170:
  store <2 x i64> <i64 1, i64 1170>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb171:
  store <2 x i64> <i64 1, i64 1171>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb172:
  store <2 x i64> <i64 1, i64 1172>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb173:
  store <2 x i64> <i64 1, i64 1173>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb174:
  store <2 x i64> <i64 1, i64 1174>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb175:
  store <2 x i64> <i64 1, i64 1175>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb176:
  store <2 x i64> <i64 1, i64 1176>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb177:
  store <2 x i64> <i64 1, i64 1177>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb178:
  store <2 x i64> <i64 1, i64 1178>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb179:
  store <2 x i64> <i64 1, i64 1179>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb180:
  store <2 x i64> <i64 1, i64 1180>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb181:
  store <2 x i64> <i64 1, i64 1181>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb182:
  store <2 x i64> <i64 1, i64 1182>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb183:
  store <2 x i64> <i64 1, i64 1183>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb184:
  store <2 x i64> <i64 1, i64 1184>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb185:
  store <2 x i64> <i64 1, i64 1185>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb186:
  store <2 x i64> <i64 1, i64 1186>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb187:
  store <2 x i64> <i64 1, i64 1187>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb188:
  store <2 x i64> <i64 1, i64 1188>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb189:
  store <2 x i64> <i64 1, i64 1189>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb190:
  store <2 x i64> <i64 1, i64 1190>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb191:
  store <2 x i64> <i64 1, i64 1191>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb192:
  store <2 x i64> <i64 1, i64 1192>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb193:
  store <2 x i64> <i64 1, i64 1193>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb194:
  store <2 x i64> <i64 1, i64 1194>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb195:
  store <2 x i64> <i64 1, i64 1195>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb196:
  store <2 x i64> <i64 1, i64 1196>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb197:
  store <2 x i64> <i64 1, i64 1197>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb198:
  store <2 x i64> <i64 1, i64 1198>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb199:
  store <2 x i64> <i64 1, i64 1199>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb200:
  store <2 x i64> <i64 1, i64 1200>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb201:
  store <2 x i64> <i64 1, i64 1201>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb202:
  store <2 x i64> <i64 1, i64 1202>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb203:
  store <2 x i64> <i64 1, i64 1203>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb204:
  store <2 x i64> <i64 1, i64 1204>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb205:
  store <2 x i64> <i64 1, i64 1205>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb206:
  store <2 x i64> <i64 1, i64 1206>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb207:
  store <2 x i64> <i64 1, i64 1207>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb208:
  store <2 x i64> <i64 1, i64 1208>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb209:
  store <2 x i64> <i64 1, i64 1209>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb210:
  store <2 x i64> <i64 1, i64 1210>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb211:
  store <2 x i64> <i64 1, i64 1211>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb212:
  store <2 x i64> <i64 1, i64 1212>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb213:
  store <2 x i64> <i64 1, i64 1213>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb214:
  store <2 x i64> <i64 1, i64 1214>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb215:
  store <2 x i64> <i64 1, i64 1215>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb216:
  store <2 x i64> <i64 1, i64 1216>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb217:
  store <2 x i64> <i64 1, i64 1217>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb218:
  store <2 x i64> <i64 1, i64 1218>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb219:
  store <2 x i64> <i64 1, i64 1219>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb220:
  store <2 x i64> <i64 1, i64 1220>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb221:
  store <2 x i64> <i64 1, i64 1221>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb222:
  store <2 x i64> <i64 1, i64 1222>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb223:
  store <2 x i64> <i64 1, i64 1223>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb224:
  store <2 x i64> <i64 1, i64 1224>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb225:
  store <2 x i64> <i64 1, i64 1225>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb226:
  store <2 x i64> <i64 1, i64 1226>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb227:
  store <2 x i64> <i64 1, i64 1227>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb228:
  store <2 x i64> <i64 1, i64 1228>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb229:
  store <2 x i64> <i64 1, i64 1229>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb230:
  store <2 x i64> <i64 1, i64 1230>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb231:
  store <2 x i64> <i64 1, i64 1231>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb232:
  store <2 x i64> <i64 1, i64 1232>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb233:
  store <2 x i64> <i64 1, i64 1233>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb234:
  store <2 x i64> <i64 1, i64 1234>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb235:
  store <2 x i64> <i64 1, i64 1235>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb236:
  store <2 x i64> <i64 1, i64 1236>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb237:
  store <2 x i64> <i64 1, i64 1237>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb238:
  store <2 x i64> <i64 1, i64 1238>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb239:
  store <2 x i64> <i64 1, i64 1239>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb240:
  store <2 x i64> <i64 1, i64 1240>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb241:
  store <2 x i64> <i64 1, i64 1241>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb242:
  store <2 x i64> <i64 1, i64 1242>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb243:
  store <2 x i64> <i64 1, i64 1243>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb244:
  store <2 x i64> <i64 1, i64 1244>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb245:
  store <2 x i64> <i64 1, i64 1245>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb246:
  store <2 x i64> <i64 1, i64 1246>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb247:
  store <2 x i64> <i64 1, i64 1247>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb248:
  store <2 x i64> <i64 1, i64 1248>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb249:
  store <2 x i64> <i64 1, i64 1249>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb250:
  store <2 x i64> <i64 1, i64 1250>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb251:
  store <2 x i64> <i64 1, i64 1251>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb252:
  store <2 x i64> <i64 1, i64 1252>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb253:
  store <2 x i64> <i64 1, i64 1253>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb254:
  store <2 x i64> <i64 1, i64 1254>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb255:
  store <2 x i64> <i64 1, i64 1255>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb256:
  store <2 x i64> <i64 1, i64 1256>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb257:
  store <2 x i64> <i64 1, i64 1257>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb258:
  store <2 x i64> <i64 1, i64 1258>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb259:
  store <2 x i64> <i64 1, i64 1259>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb260:
  store <2 x i64> <i64 1, i64 1260>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb261:
  store <2 x i64> <i64 1, i64 1261>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb262:
  store <2 x i64> <i64 1, i64 1262>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb263:
  store <2 x i64> <i64 1, i64 1263>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb264:
  store <2 x i64> <i64 1, i64 1264>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb265:
  store <2 x i64> <i64 1, i64 1265>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb266:
  store <2 x i64> <i64 1, i64 1266>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb267:
  store <2 x i64> <i64 1, i64 1267>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb268:
  store <2 x i64> <i64 1, i64 1268>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb269:
  store <2 x i64> <i64 1, i64 1269>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb270:
  store <2 x i64> <i64 1, i64 1270>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb271:
  store <2 x i64> <i64 1, i64 1271>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb272:
  store <2 x i64> <i64 1, i64 1272>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb273:
  store <2 x i64> <i64 1, i64 1273>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb274:
  store <2 x i64> <i64 1, i64 1274>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb275:
  store <2 x i64> <i64 1, i64 1275>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb276:
  store <2 x i64> <i64 1, i64 1276>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb277:
  store <2 x i64> <i64 1, i64 1277>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb278:
  store <2 x i64> <i64 1, i64 1278>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb279:
  store <2 x i64> <i64 1, i64 1279>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb280:
  store <2 x i64> <i64 1, i64 1280>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb281:
  store <2 x i64> <i64 1, i64 1281>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb282:
  store <2 x i64> <i64 1, i64 1282>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb283:
  store <2 x i64> <i64 1, i64 1283>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb284:
  store <2 x i64> <i64 1, i64 1284>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb285:
  store <2 x i64> <i64 1, i64 1285>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb286:
  store <2 x i64> <i64 1, i64 1286>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb287:
  store <2 x i64> <i64 1, i64 1287>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb288:
  store <2 x i64> <i64 1, i64 1288>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb289:
  store <2 x i64> <i64 1, i64 1289>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb290:
  store <2 x i64> <i64 1, i64 1290>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb291:
  store <2 x i64> <i64 1, i64 1291>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb292:
  store <2 x i64> <i64 1, i64 1292>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb293:
  store <2 x i64> <i64 1, i64 1293>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb294:
  store <2 x i64> <i64 1, i64 1294>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb295:
  store <2 x i64> <i64 1, i64 1295>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb296:
  store <2 x i64> <i64 1, i64 1296>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb297:
  store <2 x i64> <i64 1, i64 1297>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb298:
  store <2 x i64> <i64 1, i64 1298>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

bb299:
  store <2 x i64> <i64 1, i64 1299>, ptr %p, align 8
  call void @use(ptr %p)
  br label %exit

exit:
  ret void
}
