# 「ずんだもんのオールナイトニッポン」


[![IMAGE ALT TEXT HERE](https://jphacks.com/wp-content/uploads/2024/07/JPHACKS2024_ogp.jpg)](https://www.youtube.com/watch?v=DZXUkEj-CSI)

## 製品概要
ずんだもんがラジオパーソナリティとなって，ユーザの心境や好みに合った内容のオリジナルラジオを聞かせてくれるアプリケーション 

### 背景(製品開発のきっかけ、課題等）
-  現在、ラジオ視聴者が約10%未満と減少傾向にある。
    - 理由 ・背景
        - 「ラジオをそもそも聴いたことがない（特に若者）」
     
        - 「そもそもラジオ番組を視聴するという選択肢が無い」

        - 「興味のある番組がない 」

        - 「インターネットやテレビの方が面白い 」


- ラジオの良さを伝えたい！

    - きっかけ
        - チームメンバーに、ラジオを聴かない日は無いんじゃないかというくらいラジオが好きな人がいた。
        - ラジオには、ラジオにしかない良さがたくさんあるのに、周りで聴いている人が少なく、もどかしく感じていた。
        - ITを用いて、問題を解決することができないか？？

    - 魅力

        - 「ラジオは心を換気する」←←←ラジオ視聴サービス「radiko」が用いたキャッチコピー 

            - 時間に追われる忙しい現代人にこそ、心休まる心地良いトークを、気分を変える音楽を。仕事しながら、料理しながら、掃除しながら、気分転換。 

        - 脳科学者・加藤 俊徳氏によると、ラジオを聴くと頭が成長することを立証。 

        - 脳の疲労回復にも効果ありとのこと。

- 目的

    - そもそもラジオを聴くという選択肢や経験が無いのならば、音声合成ソフト「ずんだもん」のような魅力的な人気キャラクターを活用することでユーザーの興味を獲得することによって、ラジオと触れるきっかけを生み出したい！

    - 興味のある番組が少ないなら、ユーザーの好み・気分に合わせた番組をユーザー自身で生成してしまえばよいのでは？？
 
    - これまではせっかくリスナーからのメールを送っても、読まれる確率が低かったが、絶対にずんだもんがお便りに回答して、悩み相談に付き合ってくれることで、新たなUXの実現を！
 
      →→→メンタルヘルスの向上や、自分の書いたお便りを番組内で読み上げてもらえる嬉しさを味わうことが期待できる。
      
- そこで、生成AI「GEMINI」　×　音声合成ソフト「VOICEVOX」のずんだもん　を使ってオリジナルのラジオ番組を生成するアプリを開発しました ！

### 製品説明（具体的な製品の説明）

モバイルアプリから自分が聴きたいテーマや今の気分を選択すると，生成AIがずんだもん用のラジオ番組の原稿・セリフを生成し，ずんだもんとして自動音声で再生・放送してくれます。

また、「ずんだもんのお悩み相談室」のコーナーとして、ユーザーが「ラジオネーム」と「メールの本文」を入力して送信することで、ずんだもんがその悩みやメールの内容に沿って、ユーザーに親身に寄り添ったアドバイスや共感をしながら、ラジオ番組内で回答してくれます。

- 利用手順

    - ラジオ番組の生成

        1. ユーザーは「ラジオを聴く」か「メールを送る」を選択

            <img src="https://github.com/user-attachments/assets/a165d837-6540-45de-9eac-b4e79bf40bae" width="25%">
       
        2. カテゴリーを選択

            <img src="https://github.com/user-attachments/assets/a9a2d9f7-236f-4d40-9993-806146fe71f5" width="25%">

        3. ずんだもんのラジオ番組を視聴

            <img src="https://github.com/user-attachments/assets/f98ff281-4669-4f4b-8017-ba2b8d51a23b" width="25%">

    - リスナーメールの回答
 
        1. ラジオネームとメールを記入
 
            <img src="https://github.com/user-attachments/assets/8310eb09-df96-4491-8658-6b5051097a57" width="25%">

        2. ずんだもんが回答

            <img src="https://github.com/user-attachments/assets/f98ff281-4669-4f4b-8017-ba2b8d51a23b" width="25%">


自動音声として[VOICEBOX](https://voicevox.hiroshiba.jp/)を使用する 
### 特長
#### 1. 好きなジャンルや今の気分を入力することで、リスナーに最適化されたテーマのラジオを生成して提供してくれること 
#### 2. 回答率100%のお便りを送れることで、ラジオ番組で自分の相談に乗ってくれることの嬉しさを体験できる
#### 3. 親しみやすい魅力的で人気があるキャラクターの自動音声を利用することで、今までのラジオにはなかった新たなUXを実現

### 解決出来ること

    - ユーザーがラジオと触れ合うきっかけを創出できる

    - ラジオに興味がある番組が無かったことに対して、既存の「radiko」アプリと組み合わせて、ユーザーの興味により最適化された番組を提供できる

    - せっかくお便りを書いても読まれることがないことでがっかりしない

    - 誰かにアドバイスや相談に乗って欲しい時に、魅力的なキャラクターが相談に乗ってくれる

### 今後の展望
- Radikoと連携して実際のおすすめの番組も提示してくれる機能や他エリアやタイムフリー視聴と掛け合わせて、ラジオ番組が面白いということを多くの人々に知らせたい

- ずんだもんだけじゃなく、他の男性・女性関係ないキャラクターの音声を増やすことで、より興味が引けるコンテンツを作成する

### 注力したこと（こだわり等）
* プロンプトにこだわって，VOICEBOXのキャラに合った台本を生成するようにしたこと 


## 開発技術
### 活用した技術
#### API・データ
* Gemini API 
* 

#### フレームワーク・ライブラリ・モジュール
* Backend 

    * Firebase 

    * Gemini API 
* Frontend 

    * Flutter 

    * VOICEVOX API 

#### デバイス
* 
* 

### 独自技術
#### ハッカソンで開発した独自機能・技術
* 全部
