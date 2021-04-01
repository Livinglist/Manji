class Keys {
  ///Reserved for [Kanji]
  static String kanjiKey = 'kanji';
  static String sentencesKey = 'sentences';
  static String textKey = 'text';
  static String idKey = 'id';
  static String meaningKey = 'meaning';
  static String radicalKey = 'radicals';
  static String radicalsMeaningKey = 'radicalsMeaning';
  static String strokesKey = 'strokes';
  static String gradeKey = 'grade';
  static String jlptKey = 'jlpt';
  static String frequencyKey = 'frequency';
  static String partsKey = 'parts';
  static String kunyomiKey = 'kunyomi';
  static String onyomiKey = 'onyomi';
  static String kunyomiWordsKey = 'kunyomiWords';
  static String onyomiWordsKey = 'onyomiWords';
  static String studiedTimeStampsKey = 'studiedTimeStamps';

  ///Reserved for [Sentence]
  static String kanjiIdKey = "kanjiId";
  static String rightAnswerKey = "rightAnswer";
  static String choicesKey = "choices";
  static String selectedIndexKey = "selectedIndex";
  static String questionTypeKey = "questionType";
  static String furiganaKey = 'furigana';
  static String englishTextKey = 'englishText';
  static String tokensKey = 'tokens';

  ///Reserved for [Word]
  static String wordTextKey = 'wordText';
  static String wordFuriganaKey = 'wordFurigana';
  static String wordMeaningsKey = 'meanings';

  ///Reserved for [SharedPrefs]
  static String favKanjiStrsKey = 'favKanjiStrs';
  static String starKanjiStrsKey = 'starKanjiStrs';
  static String kanjiListStrKey = 'kanjiListStr';
  static String uidsKey = 'uids';
  static String lastFetchedAtKey = 'lastFetchedAt';
  static String themeModeKey = 'themeMode';
}

class Fonts {
  static String kazei = 'kazei';
}

const Set<String> allVideoFiles = {
  "一",
  "丁",
  "七",
  "万",
  "三",
  "上",
  "下",
  "不",
  "与",
  "世",
  "両",
  "並",
  "中",
  "丸",
  "主",
  "久",
  "乏",
  "乗",
  "九",
  "乱",
  "乳",
  "乾",
  "了",
  "予",
  "争",
  "事",
  "二",
  "互",
  "五",
  "亡",
  "交",
  "京",
  "人",
  "仁",
  "今",
  "介",
  "仏",
  "仕",
  "他",
  "付",
  "代",
  "令",
  "以",
  "仮",
  "仲",
  "件",
  "任",
  "企",
  "伏",
  "休",
  "会",
  "伝",
  "伸",
  "伺",
  "似",
  "位",
  "低",
  "住",
  "体",
  "何",
  "余",
  "作",
  "使",
  "例",
  "供",
  "依",
  "価",
  "侮",
  "便",
  "係",
  "保",
  "信",
  "修",
  "俳",
  "俵",
  "倉",
  "個",
  "倍",
  "倒",
  "候",
  "借",
  "値",
  "偉",
  "偏",
  "停",
  "健",
  "側",
  "偶",
  "備",
  "傷",
  "傾",
  "働",
  "像",
  "僕",
  "億",
  "優",
  "元",
  "兄",
  "充",
  "兆",
  "先",
  "光",
  "免",
  "児",
  "党",
  "入",
  "全",
  "八",
  "公",
  "六",
  "共",
  "兵",
  "具",
  "典",
  "内",
  "円",
  "冊",
  "再",
  "冒",
  "最",
  "冗",
  "写",
  "冬",
  "冷",
  "凍",
  "処",
  "出",
  "刀",
  "分",
  "切",
  "刊",
  "列",
  "初",
  "判",
  "別",
  "利",
  "到",
  "制",
  "刷",
  "券",
  "刺",
  "刻",
  "則",
  "前",
  "副",
  "割",
  "創",
  "劇",
  "力",
  "功",
  "加",
  "助",
  "努",
  "労",
  "効",
  "勇",
  "勉",
  "動",
  "務",
  "勝",
  "募",
  "勢",
  "勤",
  "勧",
  "包",
  "化",
  "北",
  "匹",
  "区",
  "医",
  "十",
  "千",
  "午",
  "半",
  "卒",
  "卓",
  "協",
  "南",
  "単",
  "博",
  "占",
  "印",
  "危",
  "即",
  "卵",
  "厚",
  "原",
  "厳",
  "去",
  "参",
  "友",
  "双",
  "反",
  "収",
  "取",
  "受",
  "口",
  "古",
  "句",
  "叫",
  "召",
  "可",
  "台",
  "史",
  "右",
  "号",
  "司",
  "各",
  "合",
  "同",
  "名",
  "后",
  "向",
  "君",
  "否",
  "含",
  "吸",
  "吹",
  "告",
  "周",
  "味",
  "呼",
  "命",
  "和",
  "咲",
  "品",
  "員",
  "哲",
  "唱",
  "商",
  "問",
  "善",
  "喜",
  "喫",
  "営",
  "器",
  "四",
  "回",
  "因",
  "団",
  "困",
  "囲",
  "図",
  "固",
  "国",
  "園",
  "土",
  "圧",
  "在",
  "地",
  "坂",
  "均",
  "坊",
  "垂",
  "型",
  "城",
  "埋",
  "域",
  "基",
  "堂",
  "堅",
  "報",
  "場",
  "塔",
  "塗",
  "塩",
  "境",
  "墓",
  "増",
  "壊",
  "士",
  "声",
  "売",
  "変",
  "夏",
  "夕",
  "外",
  "多",
  "夜",
  "夢",
  "大",
  "天",
  "太",
  "夫",
  "央",
  "失",
  "奏",
  "奥",
  "奨",
  "奮",
  "女",
  "好",
  "妹",
  "妻",
  "姉",
  "始",
  "姓",
  "委",
  "姿",
  "娘",
  "婚",
  "婦",
  "嫌",
  "子",
  "字",
  "存",
  "孝",
  "季",
  "学",
  "孫",
  "宅",
  "宇",
  "守",
  "安",
  "完",
  "宗",
  "官",
  "宙",
  "定",
  "宝",
  "実",
  "客",
  "宣",
  "室",
  "宮",
  "害",
  "家",
  "容",
  "宿",
  "寄",
  "密",
  "富",
  "寒",
  "寝",
  "察",
  "寮",
  "寸",
  "寺",
  "対",
  "封",
  "専",
  "将",
  "射",
  "尊",
  "導",
  "小",
  "少",
  "就",
  "尺",
  "局",
  "居",
  "届",
  "屋",
  "展",
  "属",
  "層",
  "山",
  "岩",
  "岸",
  "島",
  "川",
  "州",
  "巣",
  "工",
  "左",
  "巨",
  "差",
  "己",
  "巻",
  "市",
  "布",
  "希",
  "師",
  "席",
  "帯",
  "帰",
  "帳",
  "常",
  "帽",
  "幅",
  "幕",
  "干",
  "平",
  "年",
  "幸",
  "幹",
  "幼",
  "幾",
  "庁",
  "広",
  "床",
  "序",
  "底",
  "店",
  "府",
  "度",
  "座",
  "庫",
  "庭",
  "康",
  "延",
  "建",
  "弁",
  "式",
  "弓",
  "引",
  "弟",
  "弱",
  "張",
  "強",
  "弾",
  "当",
  "形",
  "影",
  "役",
  "彼",
  "往",
  "征",
  "径",
  "待",
  "律",
  "後",
  "徒",
  "従",
  "得",
  "御",
  "復",
  "徳",
  "心",
  "必",
  "志",
  "忘",
  "忙",
  "応",
  "忠",
  "快",
  "念",
  "怒",
  "怖",
  "思",
  "急",
  "性",
  "怪",
  "恋",
  "恐",
  "恥",
  "恩",
  "息",
  "悟",
  "患",
  "悩",
  "悪",
  "悲",
  "情",
  "想",
  "意",
  "愛",
  "感",
  "態",
  "慣",
  "憎",
  "憲",
  "成",
  "我",
  "戦",
  "戸",
  "戻",
  "所",
  "手",
  "才",
  "打",
  "払",
  "批",
  "承",
  "技",
  "抑",
  "投",
  "抗",
  "折",
  "抜",
  "抱",
  "抵",
  "押",
  "担",
  "招",
  "拝",
  "拡",
  "拾",
  "持",
  "指",
  "挙",
  "挟",
  "捕",
  "捜",
  "捨",
  "掃",
  "授",
  "掘",
  "掛",
  "採",
  "探",
  "接",
  "控",
  "推",
  "描",
  "提",
  "換",
  "揮",
  "損",
  "操",
  "支",
  "改",
  "攻",
  "放",
  "政",
  "故",
  "救",
  "敗",
  "教",
  "敢",
  "散",
  "敬",
  "数",
  "整",
  "敵",
  "文",
  "料",
  "断",
  "新",
  "方",
  "旅",
  "族",
  "旗",
  "日",
  "旧",
  "早",
  "昇",
  "明",
  "易",
  "昔",
  "星",
  "映",
  "春",
  "昨",
  "昭",
  "昼",
  "時",
  "晩",
  "普",
  "景",
  "晴",
  "暑",
  "暇",
  "暖",
  "暗",
  "暮",
  "暴",
  "曇",
  "曜",
  "曲",
  "更",
  "書",
  "替",
  "月",
  "有",
  "服",
  "朗",
  "望",
  "朝",
  "期",
  "木",
  "未",
  "末",
  "本",
  "札",
  "机",
  "材",
  "村",
  "束",
  "条",
  "来",
  "杯",
  "東",
  "松",
  "板",
  "林",
  "枚",
  "果",
  "枝",
  "枯",
  "染",
  "柔",
  "柱",
  "査",
  "栄",
  "校",
  "株",
  "根",
  "格",
  "案",
  "桜",
  "梅",
  "械",
  "棒",
  "森",
  "植",
  "検",
  "業",
  "極",
  "楽",
  "概",
  "構",
  "様",
  "標",
  "模",
  "権",
  "横",
  "樹",
  "橋",
  "機",
  "欠",
  "次",
  "欧",
  "欲",
  "歌",
  "止",
  "正",
  "武",
  "歩",
  "歯",
  "歳",
  "歴",
  "死",
  "残",
  "段",
  "殺",
  "殿",
  "母",
  "毎",
  "毒",
  "比",
  "毛",
  "氏",
  "民",
  "気",
  "水",
  "氷",
  "永",
  "求",
  "汗",
  "汚",
  "池",
  "決",
  "汽",
  "沈",
  "沢",
  "河",
  "沸",
  "油",
  "治",
  "沿",
  "況",
  "泉",
  "泊",
  "法",
  "波",
  "泣",
  "泥",
  "注",
  "泳",
  "洋",
  "洗",
  "活",
  "派",
  "流",
  "浅",
  "浮",
  "浴",
  "海",
  "消",
  "涙",
  "液",
  "涼",
  "深",
  "混",
  "清",
  "済",
  "渉",
  "減",
  "渡",
  "温",
  "測",
  "港",
  "湖",
  "湯",
  "湾",
  "湿",
  "満",
  "源",
  "準",
  "溶",
  "滴",
  "漁",
  "演",
  "漢",
  "潔",
  "潮",
  "激",
  "濃",
  "濯",
  "火",
  "灯",
  "灰",
  "災",
  "炭",
  "点",
  "無",
  "焦",
  "然",
  "焼",
  "煙",
  "照",
  "蒸",
  "熟",
  "熱",
  "燃",
  "燥",
  "爆",
  "父",
  "片",
  "版",
  "牛",
  "牧",
  "物",
  "特",
  "犬",
  "犯",
  "状",
  "狂",
  "独",
  "狭",
  "猫",
  "率",
  "玉",
  "王",
  "珍",
  "班",
  "現",
  "球",
  "理",
  "瓶",
  "甘",
  "生",
  "産",
  "用",
  "田",
  "由",
  "申",
  "男",
  "町",
  "画",
  "界",
  "畑",
  "留",
  "畜",
  "略",
  "異",
  "番",
  "畳",
  "疑",
  "疲",
  "病",
  "痛",
  "療",
  "発",
  "登",
  "白",
  "百",
  "的",
  "皆",
  "皇",
  "皮",
  "皿",
  "益",
  "盗",
  "盛",
  "盟",
  "目",
  "直",
  "相",
  "省",
  "看",
  "県",
  "真",
  "眠",
  "眼",
  "着",
  "矢",
  "知",
  "短",
  "石",
  "砂",
  "研",
  "破",
  "硬",
  "磁",
  "確",
  "磨",
  "礎",
  "示",
  "礼",
  "社",
  "祈",
  "祖",
  "祝",
  "神",
  "票",
  "祭",
  "視",
  "禁",
  "福",
  "私",
  "秋",
  "科",
  "秒",
  "秘",
  "移",
  "程",
  "税",
  "種",
  "稲",
  "穀",
  "積",
  "穫",
  "穴",
  "究",
  "空",
  "突",
  "窓",
  "立",
  "童",
  "端",
  "競",
  "竹",
  "笑",
  "笛",
  "符",
  "第",
  "筆",
  "等",
  "筋",
  "筒",
  "答",
  "策",
  "節",
  "算",
  "管",
  "箱",
  "範",
  "築",
  "簡",
  "籍",
  "米",
  "粉",
  "粒",
  "精",
  "糖",
  "糸",
  "系",
  "紀",
  "約",
  "紅",
  "納",
  "純",
  "紙",
  "級",
  "素",
  "細",
  "紹",
  "終",
  "組",
  "経",
  "結",
  "絡",
  "給",
  "統",
  "絵",
  "絶",
  "絹",
  "続",
  "綿",
  "緊",
  "総",
  "緑",
  "緒",
  "線",
  "編",
  "練",
  "縦",
  "縮",
  "績",
  "織",
  "缶",
  "罪",
  "置",
  "署",
  "羊",
  "美",
  "群",
  "義",
  "羽",
  "翌",
  "習",
  "老",
  "考",
  "者",
  "耕",
  "耳",
  "聖",
  "聞",
  "職",
  "肉",
  "肌",
  "肥",
  "肩",
  "肯",
  "育",
  "肺",
  "胃",
  "背",
  "胸",
  "能",
  "脂",
  "脈",
  "脱",
  "脳",
  "腕",
  "腰",
  "腸",
  "腹",
  "膚",
  "臓",
  "臣",
  "臨",
  "自",
  "至",
  "興",
  "舌",
  "舎",
  "舞",
  "舟",
  "航",
  "般",
  "船",
  "良",
  "色",
  "芝",
  "花",
  "芸",
  "芽",
  "若",
  "苦",
  "英",
  "茶",
  "草",
  "荒",
  "荷",
  "菓",
  "菜",
  "華",
  "著",
  "落",
  "葉",
  "蔵",
  "薄",
  "薬",
  "虫",
  "蚕",
  "血",
  "衆",
  "行",
  "術",
  "街",
  "衛",
  "衣",
  "表",
  "袋",
  "裁",
  "装",
  "裏",
  "補",
  "製",
  "複",
  "西",
  "要",
  "見",
  "規",
  "覚",
  "覧",
  "親",
  "観",
  "角",
  "解",
  "触",
  "言",
  "計",
  "討",
  "訓",
  "記",
  "訪",
  "設",
  "許",
  "訳",
  "証",
  "評",
  "詞",
  "試",
  "詩",
  "詰",
  "話",
  "詳",
  "誇",
  "誠",
  "誌",
  "認",
  "誕",
  "語",
  "誤",
  "説",
  "読",
  "誰",
  "課",
  "調",
  "談",
  "論",
  "諸",
  "講",
  "謝",
  "識",
  "警",
  "議",
  "護",
  "谷",
  "豆",
  "豊",
  "豚",
  "象",
  "貝",
  "負",
  "財",
  "貧",
  "貨",
  "販",
  "責",
  "貯",
  "貴",
  "買",
  "貸",
  "費",
  "貿",
  "賀",
  "賃",
  "資",
  "賛",
  "賞",
  "賢",
  "質",
  "贈",
  "赤",
  "走",
  "起",
  "超",
  "越",
  "趣",
  "足",
  "跡",
  "路",
  "踊",
  "身",
  "車",
  "軍",
  "軒",
  "軟",
  "転",
  "軽",
  "較",
  "輩",
  "輪",
  "輸",
  "辛",
  "辞",
  "辱",
  "農",
  "辺",
  "込",
  "迎",
  "近",
  "返",
  "述",
  "迷",
  "追",
  "退",
  "送",
  "逃",
  "逆",
  "途",
  "通",
  "速",
  "造",
  "連",
  "週",
  "進",
  "遅",
  "遊",
  "運",
  "過",
  "道",
  "達",
  "違",
  "遠",
  "適",
  "選",
  "遺",
  "避",
  "邪",
  "郊",
  "郡",
  "部",
  "郵",
  "郷",
  "都",
  "配",
  "酒",
  "酸",
  "里",
  "重",
  "野",
  "量",
  "金",
  "針",
  "鈍",
  "鉄",
  "鉱",
  "銀",
  "銅",
  "銭",
  "鋭",
  "鋼",
  "録",
  "鏡",
  "長",
  "門",
  "閉",
  "開",
  "間",
  "関",
  "閣",
  "防",
  "降",
  "限",
  "陛",
  "院",
  "除",
  "陸",
  "険",
  "陽",
  "隅",
  "隊",
  "階",
  "際",
  "障",
  "隣",
  "隻",
  "集",
  "雇",
  "雑",
  "離",
  "難",
  "雨",
  "雪",
  "雲",
  "零",
  "電",
  "震",
  "青",
  "静",
  "非",
  "面",
  "革",
  "靴",
  "音",
  "章",
  "響",
  "頂",
  "頃",
  "順",
  "預",
  "領",
  "頭",
  "頼",
  "題",
  "額",
  "顔",
  "願",
  "類",
  "風",
  "飛",
  "食",
  "飯",
  "飲",
  "飼",
  "飽",
  "養",
  "館",
  "首",
  "香",
  "馬",
  "駅",
  "駐",
  "騒",
  "験",
  "驚",
  "骨",
  "高",
  "髪",
  "魚",
  "鳥",
  "鳴",
  "鹿",
  "麦",
  "黄",
  "黒",
  "鼻",
  "齢"
};
