'use strict';

var Curry = require("../../lib/js/curry.js");
var Caml_oo_curry = require("../../lib/js/caml_oo_curry.js");
var CamlinternalOO = require("../../lib/js/camlinternalOO.js");

var shared = [
  "field0",
  "field1",
  "field2",
  "field3",
  "field4",
  "field5",
  "field6",
  "field7",
  "field8",
  "field9",
  "field10",
  "field11",
  "field12",
  "field13",
  "field14",
  "field15",
  "field16",
  "field17",
  "field18",
  "field19",
  "field20",
  "field21",
  "field22",
  "field23",
  "field24",
  "field25",
  "field26",
  "field27",
  "field28",
  "field29",
  "field30",
  "field31",
  "field32",
  "field33",
  "field34",
  "field35",
  "field36",
  "field37",
  "field38",
  "field39",
  "field40",
  "field41",
  "field42",
  "field43",
  "field44",
  "field45",
  "field46",
  "field47",
  "field48",
  "field49",
  "field50",
  "field51",
  "field52",
  "field53",
  "field54",
  "field55",
  "field56",
  "field57",
  "field58",
  "field59",
  "field60",
  "field61",
  "field62",
  "field63",
  "field64",
  "field65",
  "field66",
  "field67",
  "field68",
  "field69",
  "field70",
  "field71",
  "field72",
  "field73",
  "field74",
  "field75",
  "field76",
  "field77",
  "field78",
  "field79",
  "field80",
  "field81",
  "field82",
  "field83",
  "field84",
  "field85",
  "field86",
  "field87",
  "field88",
  "field89",
  "field90",
  "field91",
  "field92",
  "field93",
  "field94",
  "field95",
  "field96",
  "field97",
  "field98",
  "field99"
];

var shared$1 = [
  "get0",
  "get1",
  "get2",
  "get3",
  "get4",
  "get5",
  "get6",
  "get7",
  "get8",
  "get9",
  "get10",
  "get11",
  "get12",
  "get13",
  "get14",
  "get15",
  "get16",
  "get17",
  "get18",
  "get19"
];

var $$class = CamlinternalOO.create_table(shared$1);

var ids = CamlinternalOO.new_methods_variables($$class, [
      "get9",
      "get8",
      "get7",
      "get6",
      "get5",
      "get4",
      "get3",
      "get2",
      "get19",
      "get18",
      "get17",
      "get16",
      "get15",
      "get14",
      "get13",
      "get12",
      "get11",
      "get10",
      "get1",
      "get0"
    ], shared);

var get9 = ids[0];

var get8 = ids[1];

var get7 = ids[2];

var get6 = ids[3];

var get5 = ids[4];

var get4 = ids[5];

var get3 = ids[6];

var get2 = ids[7];

var get19 = ids[8];

var get18 = ids[9];

var get17 = ids[10];

var get16 = ids[11];

var get15 = ids[12];

var get14 = ids[13];

var get13 = ids[14];

var get12 = ids[15];

var get11 = ids[16];

var get10 = ids[17];

var get1 = ids[18];

var get0 = ids[19];

var field0 = ids[20];

var field1 = ids[21];

var field2 = ids[22];

var field3 = ids[23];

var field4 = ids[24];

var field5 = ids[25];

var field6 = ids[26];

var field7 = ids[27];

var field8 = ids[28];

var field9 = ids[29];

var field10 = ids[30];

var field11 = ids[31];

var field12 = ids[32];

var field13 = ids[33];

var field14 = ids[34];

var field15 = ids[35];

var field16 = ids[36];

var field17 = ids[37];

var field18 = ids[38];

var field19 = ids[39];

var field20 = ids[40];

var field21 = ids[41];

var field22 = ids[42];

var field23 = ids[43];

var field24 = ids[44];

var field25 = ids[45];

var field26 = ids[46];

var field27 = ids[47];

var field28 = ids[48];

var field29 = ids[49];

var field30 = ids[50];

var field31 = ids[51];

var field32 = ids[52];

var field33 = ids[53];

var field34 = ids[54];

var field35 = ids[55];

var field36 = ids[56];

var field37 = ids[57];

var field38 = ids[58];

var field39 = ids[59];

var field40 = ids[60];

var field41 = ids[61];

var field42 = ids[62];

var field43 = ids[63];

var field44 = ids[64];

var field45 = ids[65];

var field46 = ids[66];

var field47 = ids[67];

var field48 = ids[68];

var field49 = ids[69];

var field50 = ids[70];

var field51 = ids[71];

var field52 = ids[72];

var field53 = ids[73];

var field54 = ids[74];

var field55 = ids[75];

var field56 = ids[76];

var field57 = ids[77];

var field58 = ids[78];

var field59 = ids[79];

var field60 = ids[80];

var field61 = ids[81];

var field62 = ids[82];

var field63 = ids[83];

var field64 = ids[84];

var field65 = ids[85];

var field66 = ids[86];

var field67 = ids[87];

var field68 = ids[88];

var field69 = ids[89];

var field70 = ids[90];

var field71 = ids[91];

var field72 = ids[92];

var field73 = ids[93];

var field74 = ids[94];

var field75 = ids[95];

var field76 = ids[96];

var field77 = ids[97];

var field78 = ids[98];

var field79 = ids[99];

var field80 = ids[100];

var field81 = ids[101];

var field82 = ids[102];

var field83 = ids[103];

var field84 = ids[104];

var field85 = ids[105];

var field86 = ids[106];

var field87 = ids[107];

var field88 = ids[108];

var field89 = ids[109];

var field90 = ids[110];

var field91 = ids[111];

var field92 = ids[112];

var field93 = ids[113];

var field94 = ids[114];

var field95 = ids[115];

var field96 = ids[116];

var field97 = ids[117];

var field98 = ids[118];

var field99 = ids[119];

CamlinternalOO.set_methods($$class, [
      get0,
      (function (self$1) {
          return self$1[field0] + 0 | 0;
        }),
      get1,
      (function (self$1) {
          return self$1[field1] + 1 | 0;
        }),
      get2,
      (function (self$1) {
          return self$1[field2] + 2 | 0;
        }),
      get3,
      (function (self$1) {
          return self$1[field3] + 3 | 0;
        }),
      get4,
      (function (self$1) {
          return self$1[field4] + 4 | 0;
        }),
      get5,
      (function (self$1) {
          return self$1[field5] + 5 | 0;
        }),
      get6,
      (function (self$1) {
          return self$1[field6] + 6 | 0;
        }),
      get7,
      (function (self$1) {
          return self$1[field7] + 7 | 0;
        }),
      get8,
      (function (self$1) {
          return self$1[field8] + 8 | 0;
        }),
      get9,
      (function (self$1) {
          return self$1[field9] + 9 | 0;
        }),
      get10,
      (function (self$1) {
          return self$1[field10] + 10 | 0;
        }),
      get11,
      (function (self$1) {
          return self$1[field11] + 11 | 0;
        }),
      get12,
      (function (self$1) {
          return self$1[field12] + 12 | 0;
        }),
      get13,
      (function (self$1) {
          return self$1[field13] + 13 | 0;
        }),
      get14,
      (function (self$1) {
          return self$1[field14] + 14 | 0;
        }),
      get15,
      (function (self$1) {
          return self$1[field15] + 15 | 0;
        }),
      get16,
      (function (self$1) {
          return self$1[field16] + 16 | 0;
        }),
      get17,
      (function (self$1) {
          return self$1[field17] + 17 | 0;
        }),
      get18,
      (function (self$1) {
          return self$1[field18] + 18 | 0;
        }),
      get19,
      (function (self$1) {
          return self$1[field19] + 19 | 0;
        })
    ]);

function obj_init(env) {
  var self = CamlinternalOO.create_object_opt(undefined, $$class);
  self[field0] = 0;
  self[field1] = 1;
  self[field2] = 2;
  self[field3] = 3;
  self[field4] = 4;
  self[field5] = 5;
  self[field6] = 6;
  self[field7] = 7;
  self[field8] = 8;
  self[field9] = 9;
  self[field10] = 10;
  self[field11] = 11;
  self[field12] = 12;
  self[field13] = 13;
  self[field14] = 14;
  self[field15] = 15;
  self[field16] = 16;
  self[field17] = 17;
  self[field18] = 18;
  self[field19] = 19;
  self[field20] = 20;
  self[field21] = 21;
  self[field22] = 22;
  self[field23] = 23;
  self[field24] = 24;
  self[field25] = 25;
  self[field26] = 26;
  self[field27] = 27;
  self[field28] = 28;
  self[field29] = 29;
  self[field30] = 30;
  self[field31] = 31;
  self[field32] = 32;
  self[field33] = 33;
  self[field34] = 34;
  self[field35] = 35;
  self[field36] = 36;
  self[field37] = 37;
  self[field38] = 38;
  self[field39] = 39;
  self[field40] = 40;
  self[field41] = 41;
  self[field42] = 42;
  self[field43] = 43;
  self[field44] = 44;
  self[field45] = 45;
  self[field46] = 46;
  self[field47] = 47;
  self[field48] = 48;
  self[field49] = 49;
  self[field50] = 50;
  self[field51] = 51;
  self[field52] = 52;
  self[field53] = 53;
  self[field54] = 54;
  self[field55] = 55;
  self[field56] = 56;
  self[field57] = 57;
  self[field58] = 58;
  self[field59] = 59;
  self[field60] = 60;
  self[field61] = 61;
  self[field62] = 62;
  self[field63] = 63;
  self[field64] = 64;
  self[field65] = 65;
  self[field66] = 66;
  self[field67] = 67;
  self[field68] = 68;
  self[field69] = 69;
  self[field70] = 70;
  self[field71] = 71;
  self[field72] = 72;
  self[field73] = 73;
  self[field74] = 74;
  self[field75] = 75;
  self[field76] = 76;
  self[field77] = 77;
  self[field78] = 78;
  self[field79] = 79;
  self[field80] = 80;
  self[field81] = 81;
  self[field82] = 82;
  self[field83] = 83;
  self[field84] = 84;
  self[field85] = 85;
  self[field86] = 86;
  self[field87] = 87;
  self[field88] = 88;
  self[field89] = 89;
  self[field90] = 90;
  self[field91] = 91;
  self[field92] = 92;
  self[field93] = 93;
  self[field94] = 94;
  self[field95] = 95;
  self[field96] = 96;
  self[field97] = 97;
  self[field98] = 98;
  self[field99] = 99;
  return self;
}

CamlinternalOO.init_class($$class);

var raw_object = obj_init(undefined);

if (Caml_oo_curry.js1(291536124, 1, raw_object) !== 34) {
  throw {
        RE_EXN_ID: "Assert_failure",
        _1: [
          "large_obj_test.ml",
          124,
          10
        ],
        Error: new Error()
      };
}

function raw_class_init($$class) {
  var value = CamlinternalOO.new_variable($$class, "");
  var ids = CamlinternalOO.new_methods_variables($$class, [
        "get9",
        "get8",
        "get7",
        "get6",
        "get5",
        "get4",
        "get3",
        "get2",
        "get19",
        "get18",
        "get17",
        "get16",
        "get15",
        "get14",
        "get13",
        "get12",
        "get11",
        "get10",
        "get1",
        "get0",
        "*dummy method*"
      ], shared);
  var get9 = ids[0];
  var get8 = ids[1];
  var get7 = ids[2];
  var get6 = ids[3];
  var get5 = ids[4];
  var get4 = ids[5];
  var get3 = ids[6];
  var get2 = ids[7];
  var get19 = ids[8];
  var get18 = ids[9];
  var get17 = ids[10];
  var get16 = ids[11];
  var get15 = ids[12];
  var get14 = ids[13];
  var get13 = ids[14];
  var get12 = ids[15];
  var get11 = ids[16];
  var get10 = ids[17];
  var get1 = ids[18];
  var get0 = ids[19];
  var field0 = ids[21];
  var field1 = ids[22];
  var field2 = ids[23];
  var field3 = ids[24];
  var field4 = ids[25];
  var field5 = ids[26];
  var field6 = ids[27];
  var field7 = ids[28];
  var field8 = ids[29];
  var field9 = ids[30];
  var field10 = ids[31];
  var field11 = ids[32];
  var field12 = ids[33];
  var field13 = ids[34];
  var field14 = ids[35];
  var field15 = ids[36];
  var field16 = ids[37];
  var field17 = ids[38];
  var field18 = ids[39];
  var field19 = ids[40];
  var field20 = ids[41];
  var field21 = ids[42];
  var field22 = ids[43];
  var field23 = ids[44];
  var field24 = ids[45];
  var field25 = ids[46];
  var field26 = ids[47];
  var field27 = ids[48];
  var field28 = ids[49];
  var field29 = ids[50];
  var field30 = ids[51];
  var field31 = ids[52];
  var field32 = ids[53];
  var field33 = ids[54];
  var field34 = ids[55];
  var field35 = ids[56];
  var field36 = ids[57];
  var field37 = ids[58];
  var field38 = ids[59];
  var field39 = ids[60];
  var field40 = ids[61];
  var field41 = ids[62];
  var field42 = ids[63];
  var field43 = ids[64];
  var field44 = ids[65];
  var field45 = ids[66];
  var field46 = ids[67];
  var field47 = ids[68];
  var field48 = ids[69];
  var field49 = ids[70];
  var field50 = ids[71];
  var field51 = ids[72];
  var field52 = ids[73];
  var field53 = ids[74];
  var field54 = ids[75];
  var field55 = ids[76];
  var field56 = ids[77];
  var field57 = ids[78];
  var field58 = ids[79];
  var field59 = ids[80];
  var field60 = ids[81];
  var field61 = ids[82];
  var field62 = ids[83];
  var field63 = ids[84];
  var field64 = ids[85];
  var field65 = ids[86];
  var field66 = ids[87];
  var field67 = ids[88];
  var field68 = ids[89];
  var field69 = ids[90];
  var field70 = ids[91];
  var field71 = ids[92];
  var field72 = ids[93];
  var field73 = ids[94];
  var field74 = ids[95];
  var field75 = ids[96];
  var field76 = ids[97];
  var field77 = ids[98];
  var field78 = ids[99];
  var field79 = ids[100];
  var field80 = ids[101];
  var field81 = ids[102];
  var field82 = ids[103];
  var field83 = ids[104];
  var field84 = ids[105];
  var field85 = ids[106];
  var field86 = ids[107];
  var field87 = ids[108];
  var field88 = ids[109];
  var field89 = ids[110];
  var field90 = ids[111];
  var field91 = ids[112];
  var field92 = ids[113];
  var field93 = ids[114];
  var field94 = ids[115];
  var field95 = ids[116];
  var field96 = ids[117];
  var field97 = ids[118];
  var field98 = ids[119];
  var field99 = ids[120];
  CamlinternalOO.set_methods($$class, [
        get0,
        (function (self$2) {
            return self$2[field0] + 0 | 0;
          }),
        get1,
        (function (self$2) {
            return self$2[field1] + 1 | 0;
          }),
        get2,
        (function (self$2) {
            return self$2[field2] + 2 | 0;
          }),
        get3,
        (function (self$2) {
            return self$2[field3] + 3 | 0;
          }),
        get4,
        (function (self$2) {
            return self$2[field4] + 4 | 0;
          }),
        get5,
        (function (self$2) {
            return self$2[field5] + 5 | 0;
          }),
        get6,
        (function (self$2) {
            return self$2[field6] + 6 | 0;
          }),
        get7,
        (function (self$2) {
            return self$2[field7] + 7 | 0;
          }),
        get8,
        (function (self$2) {
            return self$2[field8] + 8 | 0;
          }),
        get9,
        (function (self$2) {
            return self$2[field9] + 9 | 0;
          }),
        get10,
        (function (self$2) {
            return self$2[field10] + 10 | 0;
          }),
        get11,
        (function (self$2) {
            return self$2[field11] + 11 | 0;
          }),
        get12,
        (function (self$2) {
            return self$2[field12] + 12 | 0;
          }),
        get13,
        (function (self$2) {
            return self$2[field13] + 13 | 0;
          }),
        get14,
        (function (self$2) {
            return self$2[field14] + 14 | 0;
          }),
        get15,
        (function (self$2) {
            return self$2[field15] + 15 | 0;
          }),
        get16,
        (function (self$2) {
            return self$2[field16] + 16 | 0;
          }),
        get17,
        (function (self$2) {
            return self$2[field17] + 17 | 0;
          }),
        get18,
        (function (self$2) {
            return self$2[field18] + 18 | 0;
          }),
        get19,
        (function (self$2) {
            return self$2[field19] + 19 | 0;
          })
      ]);
  return function (env, self, value$1) {
    var self$1 = CamlinternalOO.create_object_opt(self, $$class);
    self$1[value] = value$1;
    self$1[field0] = 0;
    self$1[field1] = (value$1 << 0);
    self$1[field2] = (value$1 << 1);
    self$1[field3] = Math.imul(3, value$1);
    self$1[field4] = (value$1 << 2);
    self$1[field5] = Math.imul(5, value$1);
    self$1[field6] = Math.imul(6, value$1);
    self$1[field7] = Math.imul(7, value$1);
    self$1[field8] = (value$1 << 3);
    self$1[field9] = Math.imul(9, value$1);
    self$1[field10] = Math.imul(10, value$1);
    self$1[field11] = Math.imul(11, value$1);
    self$1[field12] = Math.imul(12, value$1);
    self$1[field13] = Math.imul(13, value$1);
    self$1[field14] = Math.imul(14, value$1);
    self$1[field15] = Math.imul(15, value$1);
    self$1[field16] = (value$1 << 4);
    self$1[field17] = Math.imul(17, value$1);
    self$1[field18] = Math.imul(18, value$1);
    self$1[field19] = Math.imul(19, value$1);
    self$1[field20] = Math.imul(20, value$1);
    self$1[field21] = Math.imul(21, value$1);
    self$1[field22] = Math.imul(22, value$1);
    self$1[field23] = Math.imul(23, value$1);
    self$1[field24] = Math.imul(24, value$1);
    self$1[field25] = Math.imul(25, value$1);
    self$1[field26] = Math.imul(26, value$1);
    self$1[field27] = Math.imul(27, value$1);
    self$1[field28] = Math.imul(28, value$1);
    self$1[field29] = Math.imul(29, value$1);
    self$1[field30] = Math.imul(30, value$1);
    self$1[field31] = Math.imul(31, value$1);
    self$1[field32] = (value$1 << 5);
    self$1[field33] = Math.imul(33, value$1);
    self$1[field34] = Math.imul(34, value$1);
    self$1[field35] = Math.imul(35, value$1);
    self$1[field36] = Math.imul(36, value$1);
    self$1[field37] = Math.imul(37, value$1);
    self$1[field38] = Math.imul(38, value$1);
    self$1[field39] = Math.imul(39, value$1);
    self$1[field40] = Math.imul(40, value$1);
    self$1[field41] = Math.imul(41, value$1);
    self$1[field42] = Math.imul(42, value$1);
    self$1[field43] = Math.imul(43, value$1);
    self$1[field44] = Math.imul(44, value$1);
    self$1[field45] = Math.imul(45, value$1);
    self$1[field46] = Math.imul(46, value$1);
    self$1[field47] = Math.imul(47, value$1);
    self$1[field48] = Math.imul(48, value$1);
    self$1[field49] = Math.imul(49, value$1);
    self$1[field50] = Math.imul(50, value$1);
    self$1[field51] = Math.imul(51, value$1);
    self$1[field52] = Math.imul(52, value$1);
    self$1[field53] = Math.imul(53, value$1);
    self$1[field54] = Math.imul(54, value$1);
    self$1[field55] = Math.imul(55, value$1);
    self$1[field56] = Math.imul(56, value$1);
    self$1[field57] = Math.imul(57, value$1);
    self$1[field58] = Math.imul(58, value$1);
    self$1[field59] = Math.imul(59, value$1);
    self$1[field60] = Math.imul(60, value$1);
    self$1[field61] = Math.imul(61, value$1);
    self$1[field62] = Math.imul(62, value$1);
    self$1[field63] = Math.imul(63, value$1);
    self$1[field64] = (value$1 << 6);
    self$1[field65] = Math.imul(65, value$1);
    self$1[field66] = Math.imul(66, value$1);
    self$1[field67] = Math.imul(67, value$1);
    self$1[field68] = Math.imul(68, value$1);
    self$1[field69] = Math.imul(69, value$1);
    self$1[field70] = Math.imul(70, value$1);
    self$1[field71] = Math.imul(71, value$1);
    self$1[field72] = Math.imul(72, value$1);
    self$1[field73] = Math.imul(73, value$1);
    self$1[field74] = Math.imul(74, value$1);
    self$1[field75] = Math.imul(75, value$1);
    self$1[field76] = Math.imul(76, value$1);
    self$1[field77] = Math.imul(77, value$1);
    self$1[field78] = Math.imul(78, value$1);
    self$1[field79] = Math.imul(79, value$1);
    self$1[field80] = Math.imul(80, value$1);
    self$1[field81] = Math.imul(81, value$1);
    self$1[field82] = Math.imul(82, value$1);
    self$1[field83] = Math.imul(83, value$1);
    self$1[field84] = Math.imul(84, value$1);
    self$1[field85] = Math.imul(85, value$1);
    self$1[field86] = Math.imul(86, value$1);
    self$1[field87] = Math.imul(87, value$1);
    self$1[field88] = Math.imul(88, value$1);
    self$1[field89] = Math.imul(89, value$1);
    self$1[field90] = Math.imul(90, value$1);
    self$1[field91] = Math.imul(91, value$1);
    self$1[field92] = Math.imul(92, value$1);
    self$1[field93] = Math.imul(93, value$1);
    self$1[field94] = Math.imul(94, value$1);
    self$1[field95] = Math.imul(95, value$1);
    self$1[field96] = Math.imul(96, value$1);
    self$1[field97] = Math.imul(97, value$1);
    self$1[field98] = Math.imul(98, value$1);
    self$1[field99] = Math.imul(99, value$1);
    return self$1;
  };
}

var raw_class = CamlinternalOO.make_class(shared$1, raw_class_init);

var v = Curry._2(raw_class[0], undefined, 3);

if (Caml_oo_curry.js1(291536121, 2, v) !== 56) {
  throw {
        RE_EXN_ID: "Assert_failure",
        _1: [
          "large_obj_test.ml",
          251,
          2
        ],
        Error: new Error()
      };
}

exports.raw_object = raw_object;
exports.raw_class = raw_class;
exports.v = v;
/* class Not a pure module */
