# hateblog-sh
はてなブログの記事の作成・編集・投稿・削除をコマンドラインだけで完結したい.

そんなきみがちょっとだけ幸せになれるかもしれないシェルスクリプトだよ. (bashじゃなくてsh)

- [Description](#description)
- [Requirement](#requirement)
- [Installation](#installation)
- [Getting-Started-Guide](#getting-started-guide)
- [Usage](#usage)
- [Direcotry/File-Layout](#direcotryfile-Layout)
- [Warning](#warning)
- [Contribution](#contribution)
- [Licence](#licence)
- [Author](#author)


## Description
下のような流れ作業を対話的にサクサクできるよ.

- 記事の作成: テンプレートの選択 => 編集 => 投稿
- 記事の編集: 記事の選択 => 編集 => 差分確認 => 投稿
- 記事の削除: 記事の選択 => 削除

おまけに、非対話的に下のようなこともできちゃうよ.

- 任意の項目リスト作成(タイトルとか投稿日とか)
- 任意のリクエスト送信(記事の一括削除や投稿など)

はてなブログの操作は[はてなブログAtomPub](http://developer.hatena.ne.jp/ja/documents/blog/apis/atom)のAPIを使うよ.

今のところ対応しているのはMarkdown形式の記事のみだよ.


## Requirement
このスクリプトは下のツールを利用するよ. 予めインストールしておいてね.

- [curl](https://github.com/curl/curl)
- [fzf](https://github.com/junegunn/fzf)

ちなみにこれらのツールを利用している処理はこんな感じ.

|処理                |利用ツール
|:-------------------|:---------------------------------
|記事の取得/投稿/削除|curl
|記事やファイルの選択|fzf (設定でpecoなどに変更可能)
|記事の編集          |環境変数EDITOR(or vi) (設定で変更可能)


## Installation
好きなディレクトリにダウンロード後、ダウンロードディレクトリに移動して'install.sh'を実行してね.

下は`~/.hateblog-sh`にインストールして、`/home/myname/bin`から実行用のリンクを貼る例だよ.

```
$ git clone https://github.com/hacolab/hateblog-sh ~/.hateblog-sh
$ cd ~/.hateblog-sh
$ sh install.sh
Hi, this is hateblog-sh install script.
Do you want to install hateblog-sh on your system?(y/n)> y
... Complete append execute permit to scripts!
Do you want to make link to hblg from other directory?(y/n)> y
Please input make link directory path. exp) /home/user-name/bin
Install Path> /home/myname/bin
... Complete linked to '/home/myname/bin'!
Let's config blog by 'hblg cn'
```

実際にやっていることは、必要なスクリプトに実行権限を追加して、指定ディレクトリからリンクを貼っているよ.  
ディレクトリはパスの通ったディレクトリを指定してね.  


## Getting Started Guide
このシェルスクリプトを使いはじめるためのチュートリアルだよ.

### ブログの登録
インストールが終わったら、きみのブログを登録しよう.  
下のコマンドを打つと、はてなブログIDの入力を求められる.  
きみのはてなブログIDを入力してね.  
例では`myblog.hatenablog.com`を入力しているよ.  

```
$ hblg config new       # ブログの登録(hblg cnでも同じ)
New BlogID > myblog.hatenablog.com
```

入力を確定したら、設定ファイルの編集だ.  
勝手に下のような設定ファイルをエディタで開くと思う.(#から始まるのはコメント行)  
きみのはてなIDとAtomPubのAPIキーを入力しよう.
AtomPubのAPIキーは[はてなブログの詳細設定ページ](http://blog.hatena.ne.jp/my/config/detail)で確認できるよ.  
各設定項目の説明は[こちら](#各ブログ用の設定ファイル)を見てね.  

```
# Your Blog ID : exp) blog-name.hatena.com
BLOG_ID=myblog.hatenablog.com
# Your hatena ID
HATENA_ID=
# Your hatena blog api key
API_KEY=
# Auto backup enable(ON|OFF)
AUTO_BACKUP=OFF
```

設定が終わったら、保存してエディタを閉じよう.  
閉じると下のようにデフォルトのブログに設定するか確認されるよ.

実はこのスクリプトは無駄に複数のブログを登録できるようになっているんだ.  
ブログの指定は`-b`オプションでできるけど、指定しないときはデフォルトに設定したブログに対して操作を行うよ.  
最初のブログなので必ず`y`を入力してEnterキーを押してね.

```
'myblog.hatenablog.com' set to default blog?(y/n)> y
```

設定が正しくできているか、下のコマンドで確認しよう.  
ちょっとコマンドの実行終了まで時間がかかるかもしれない.  
もし何もメッセージが出ずに終了したら正しく設定できていると思うよ.  

```
$ hblg fetch             # 記事リストの取得・作成
```

もし何かメッセージが出たとしたら、HTTPリクエストとレスポンスのメッセージじゃないかな？  
下の表のエラーメッセージの原因と対策を確認してみてね.  

|エラーメッセージ            |考えられる原因           |対策
|:---------------------------|:------------------------|:-----------------------------
|< HTTP/1.1 401 Unauthorized |はてなIDやAPIキーの誤り  |`hblg ce`で設定見直し
|< HTTP/1.1 403 Forbidden    |ブログIDの誤り           |`hblg cn`で新しくブログを登録<br>`hblg cd`で誤ったブログ設定を削除

その他のHTTPレスポンスについては[こちら](http://developer.hatena.ne.jp/ja/documents/blog/apis/atom#p6)を参考にしてね.

### 使用するコマンドの設定(全ブログ共通設定)
このスクリプトで使うツールを、きみが使いやすいものに変えておこう.
下のコマンドを打つと、設定ファイルを開くよ.

```
$ hblg config common    # 共通設定の編集(hblg ccでも同じ)
```

設定ファイルは下みたいな感じ. (#から始まるのはコメント行)
各設定項目の説明は[こちら](#共通の設定ファイル)を見てね.  

```
# Use default BlogID (auto set this value)
DEFAULT_BLOG_ID=myblog.hatenablog.com
# Use editor (if null use '\$EDITOR' or vi)
EDITOR=
# Diff viewer (when not equal post response vs local file)
DIFF_VIEWER=diff -u
# File selector (Use command 'draft edit', 'config edit', etc...)
FILE_SELECTOR=fzf --select-1 --no-sort --preview='head -n 60 {}'
# Not File list selector (Use 'edit')
LINE_SELECTOR=fzf --select-1 --no-sort
```

記事の編集や差分確認に使う、EDITORとDIFF_VIEWERは変えておくと幸せかもしれない.  
nvimを使いたい場合は下みたいな感じ.  

```
EDITOR=nvim
DIFF_VIEWER=nvim -d
```

もし`fzf`ではなくて他の選択ツールを使いたい場合は、FILE_SELECTOR, LINE_SELECTORを変更しよう.
[peco](https://github.com/peco/peco)を使いたい場合は下みたいな感じ.  
今のところ複数選択には対応していないので注意してね.  

```
FILE_SELECTOR=peco --select-1
LINE_SELECTOR=peco --select-1
```

設定が終わったら、保存してエディタを閉じよう.

### はじめての記事作成
それでは新しい記事を作成してみよう.  
まずは下のコマンドを実行してみてね.  

```
$ hblg new              # 記事の新規作成(hblg nでも同じ)
```

すると勝手にエディタが開いて新しい記事の編集状態になると思う. 
(テンプレートが複数ある場合は、テンプレート選択画面が出るよ)

デフォルトの記事のテンプレートフォーマットは下みたいな感じ.  

```


yes
(exp cate1,cate2...)
#Title

[:contents]
```

空行の1〜2行目と、3行目は投稿に必要な情報が入る場所.  
新規作成時はそのままにしておいてね.  
4行目は記事のカテゴリをカンマ区切りで入力しよう.  
5行目が記事のタイトル、6行目以降は記事本文になるよ.  
本文はMarkdown形式で記載してね.  

サンプル記事は下みたいな感じ.

```


yes
カテゴリだよ,diary
#これはタイトルだよ
これ以降は本文だよ.

はてなブログを操作するシェルスクリプトを書いたよ.

詳細は[こちら](https://github.com/hacolab/hateblog-sh)を見てね.


```

記事を編集し終わったら、保存してエディタを閉じよう.  

すると下のような確認が出てくるので、`y`か`n`で答えてね.  
ちなみに投稿しなかった未投稿記事は、`hblg draft edit (またはhblg de)`で編集できるよ.

```
Upload now?(y/n)> y     # y: 今すく投稿        n: 投稿しない
Draft?(y/n)> y          # y: 下書きとして投稿  n: 公開記事として投稿
```

投稿後は、投稿した記事とはてなブログのサーバに実際に保存された記事の差分が出るので確認しておこう.  
差分が出るとしたら、気にしなくていい最初の2行とタイトルの先頭末尾の空白削除くらいじゃないかな.  
(それ以外はバグの可能性が高いかも)

下のようにローカルのファイルをサーバから取得したファイルで上書くか確認される.
`y`か`n`で答えてね.  

```
Update local file(by response contents)?(y/n)> y
# y: サーバへ保存したファイルでローカルファイルを上書き
# n: ローカルファイルの状態はそのまま保持(差分確認で不都合があったとき用. hblg editで再編集してね)
```

以上で、記事の新規作成から投稿までは終わりだよ.

### 投稿済み記事の編集
つぎに、投稿済みの記事を編集してみよう.  
下のコマンドを打つと記事一覧が表示されるので、好きな記事を選ぼう.  

```
$ hblg edit             # 投稿済み記事の編集
```

記事を選ぶと選んだ記事のファイルが勝手に開くよ.

あとは基本的には新しい記事の作成と同じだけど、エディタを閉じた後に、
投稿済みの記事と投稿しようとしている記事の差分が表示されるよ.  
(差分がない場合は、変更されてない旨のメッセージが出るだけ)

差分に問題がなければ、(差分ビューワを閉じて)下の確認に答えてね.

```
Upload now?(y/n)> y     # y: 今すく投稿        n: 投稿しない
Draft?(y/n)> y          # y: 下書きとして投稿  n: 公開記事として投稿
```

ちなみに一度公開した記事は、下書きには戻せないんだ.  
スクリプトが悪いのか、はてなブログのAPIの仕様なのかは知らないけど、  
ひとまず今は、下書きに戻したい時はブラウザから操作しないといけない.
ごめんよ.

さて、以上でチュートリアルは終わりだよ.

おつかれさま.

他のコマンドについては[Usage](#Usage)を見てね.


## Usage
基本的な使い方は、やりたいこと別に用意されたコマンドを叩く感じだよ.  
とりあえず使ってみたい人は、[チュートリアル](#getting-started-guide)を参考にしてね.  

```

```

### 設定コマンド
ブログや使用するツールの設定を行うコマンド.

```
$ hblg config new       # ブログ設定ファイルの作成 (hblg cn)
$ hblg config edit      # ブログ設定ファイルの編集 (hblg ce)
$ hblg config delete    # ブログ設定ファイルの削除 (hblg cd)
$ hblg config common    # 使用ツールなどの共通設定 (hblg cc)
```

設定ファイルを選んでエディタで編集するだけ.

#### 各ブログ用の設定ファイル
設定項目の意味はそれぞれ下みたいな感じ.

|項目          |説明
|:-------------|:-------------------------------------------------------
|BLOG_ID       |はてなブログドメイン
|HATENA_ID     |はてなID
|API_KEY       |AtomPubのAPIキー([はてなブログの詳細設定ページ](http://blog.hatena.ne.jp/my/config/detail)に記載)
|AUTO_BACKUP   |投稿や削除前の記事ファイル自動保存の有効/無効 (ON/OFF)


#### 共通の設定ファイル
設定項目の意味はそれぞれ下みたいな感じ.

|項目          |説明
|:-------------|:------------------------------------------------------------------
|EDITOR        |記事編集などに使うコマンド. 未指定時は環境変数のEDITOR(or vi)を使う
|DIFF_VIEWER   |投稿前後の記事内容の差分確認に使うコマンド
|FILE_SELECTOR |ファイル選択に使うコマンド
|LINE_SELECTOR |記事リストからの記事選択などに使うコマンド

### 記事編集系コマンド
主に普段使うのは、下のコマンドだと思うよ.  

```
$ hblg entry new                # 記事の新規作成 (hblg en | hblg n)
$ hblg entry new [TemplateName] # 指定テンプレートから記事の新規作成 (hblg en | hblg n)
$ hblg entry fetch              # 投稿済み記事リストの作成・更新 (hblg ef | hblg f)
$ hblg entry fetch -f           # 投稿済み記事リストの作成・更新と記事の取得保存   (hblg f -f)
$ hblg entry edit               # 投稿済み記事の編集(ローカルに記事がなければ取得) (hblg ee | hblg e)
$ hblg entry delete             # 投稿済み記事の削除 (hblg ed | hblg d)
$ hblg draft edit               # 未投稿記事の編集   (hblg de)
$ hblg draft delete             # 未投稿記事の削除   (hblg dd)
```

基本的に最初に一度fetchして記事リストを更新しておけばいいと思うよ.  
(あとは記事を選んだときに勝手に取得するよ)

#### 記事ファイルフォーマット
取得した投稿済みの記事はローカルにMarkdownファイルとして保存するよ.

ファイルの1〜4行目は記事を投稿する際に必要なヘッダ情報だよ.  
5行目以降が記事のタイトルと内容になるよ.  

|行番号   |説明
|:--------|:-------------------------------------------------
|1行目    |エントリID. 空の場合は新しい記事として投稿
|2行目    |更新日時(updatedタグ). 空欄の場合は投稿日時を使用
|3行目    |下書きか否か(yes|no)
|4行目    |カテゴリ(複数の場合はカンマ区切り)
|5行目    |記事タイトル
|6行目以降|記事本文(Markdown形式)

下は記事ファイルのサンプル.

```
12345678901234567
2019-09-20T20:31:59+09:00
yes
diary,memo
#ここが記事タイトルになるよ
以降は記事本文になるよ

Markdown形式で書けるよ

[:contents]

## 見出し1
  ...
  ...
  ...
## 見出し2
  ...
  ...
  ...
```

### 記事テンプレート編集コマンド
テンプレートを用意しておけば、選択したテンプレートを元に新しい記事を書きはじめることができるよ.

```
$ hblg template new     # テンプレートファイルの作成 (hblg tn)
$ hblg template edit    # テンプレートファイルの編集 (hblg te)
$ hblg template delete  # テンプレートファイルの削除 (hblg td)
```

### おまけコマンド

#### 任意の項目リストの生成
はてなブログAtomPubで取得できる任意の項目のリストを生成できるよ.  
(1つの記事の情報を１行にまとめて出力)

```
$ hblg list local published title   # 記事公開日時,タイトルの一覧(ローカルの記事リストから生成)
$ hblg list server published title  # 記事公開日時,タイトルの一覧(サーバーから取得して生成)
$ hblg ll published title           # hblg list localの略記系
$ hblg ls published title           # hblg list serverの略記系
```

出力データは下みたいな感じだよ.  
項目の区切り文字は`>`で、引数で並べた順番で項目を出力するよ.  

```
$ hblg list category title draft
カテゴリだよ>タイトル(And記号などは`&amp;`などにエスケープされるよ)>yes
カテゴリ1,カテゴリ2>カテゴリが複数ある場合はカンマ区切りになるよ>no
>カテゴリがない場合は空文字だよ>yes
```

##### 取得できる項目
`local`を指定した場合は、ローカルに作成済みの記事一覧から生成. 速い.
`server`を指定した場合は、はてなブログのサーバーから取得してから生成. ちょっと遅いけど取得できる項目多め.

取得できる項目は下.  (x: 取得できる / -: 取得できない)

|項目名     |元のXMLタグ        |local|server|説明
|:----------|:------------------|:---:|:----:|------------------------------------
|author     |author>name        |  x  |  x   |投稿者(はてなID)
|alternate  |link rel=alternate |  -  |  x   |記事公開URL
|edit       |link rel=edit      |  x  |  x   |記事編集URL
|entry_id   |link rel=edit      |  x  |  x   |エントリID(link rel=editから抜き出し)
|title      |<== 同じ           |  x  |  x   |記事タイトル
|updated    |<== 同じ           |  -  |  x   |記事を公開したときに表示する更新日時
|published  |<== 同じ           |  x  |  x   |記事投稿日時
|edited     |app:edited         |  x  |  x   |最後に記事を編集した日時
|draft      |app:draft          |  x  |  x   |下書き状態(yes|no)
|summary    |<== 同じ           |  -  |  x   |記事概要

#### 任意のリクエスト送信
はてなブログAtomPubへ好きなリクエストを送信できるよ.  
いずれもHTTPレスポンスのBODYをstdoutに出力するよ.  

```
$ hblg request get category                   # カテゴリのコレクション取得
$ hblg request get entry                      # 記事のコレクションを全ページ取得
$ hblg request get entry -l 15                # 15件分の記事を取得するまでコレクションページを取得
$ hblg request get entry/<EntryID>            # 指定エントリIDの記事のコレクション取得
$ hblg request delete <EntryID>               # 指定のエントリIDの記事を削除
$ hblg request post <TxFile>                  # 指定の記事ファイル(XML or Markdown形式)を新規投稿
$ hblg request put <TxFile(XML)> エントリID   # 指定の記事ファイル(XML形式)を再投稿
$ hblg request put <TxFile(MD)> [エントリID]  # 指定の記事ファイル(Markdown形式)を再投稿
```

`post`と`put`について補足しておこう.

`<TxFile>`に指定できるのはXML形式のファイルか、`hblg new`や`hblg edit`で作成したヘッダ情報付きのMarkdown形式のファイルだよ.  
1行目に`<?xml version="1.0" encoding="utf-8"?>`の記載があればXMLをそのままリクエストのBODYとして送るよ.  

`put`でXML形式のファイルを指定した場合、引数のエントリIDは必須だよ.  
Markdown形式で引数を指定した場合、引数のエントリIDの記事として投稿するよ.  
引数を省略した場合は、指定したファイルの1行目のエントリIDの記事として投稿するよ.  

はてなブログAtomPubの詳細は[こちら](http://developer.hatena.ne.jp/ja/documents/blog/apis/atom)を見てね.

ちなみにこのコマンドによる記事の操作では自動バックアップは機能しないから気をつけてね.

##### 使用例1) 全ての記事を一括削除する
下のコマンドを打てば、きみのブログの全ての記事を削除できるよ.  
投稿済みの記事数によっては時間がかかると思うから、放置してね.  

```
$ hblg list server entry_id | xargs -L 1 -t hblg request delete
```

ちなみに下書きの記事だけ消したいときは、下みたいな感じかな.

```
$ hblg ls draft entry_id | grep "^yes" | xargs -L 1 -t hblg rq delete
```

##### 使用例2) 指定ディレクトリの記事を一括で投稿する
下のコマンドを打てば、指定ディレクトリ配下の記事をまとめて新規投稿できるよ.
ファイル数によっては時間がかかると思うから、放置してね.  

```
$ find dir/*.md | xargs -L 1 -t hblg request post
```


## Direcotry/File Layout
このスクリプトで利用するディレクトリやファイル達はこちら.

### 設定ファイルとテンプレートファイル

```
${XDG_CONFIG_DIR}/hateblog/
|-- config          ... 共通の設定ファイル
|
|-- {BlogID}        ... 各ブログごとの設定ディレクトリ
|   |-- config      ... ブログごとの設定ファイル
|   |
|   |-- template/   ... 記事テンプレートの保存ディレクトリ
|   |   |-- diary.md
|   |   |-- memo.md
```

`$XDG_CONFIG_DIR`が未定義の場合は、`${HOME}/.config/hateblog/`配下に作るよ.

### 各記事データ

```
${XDG_DATA_DIR}/hateblog/
|-- {BlogID}/       ... 各ブログごとのデータディレクトリ
|   |-- list        ... 投稿済み記事の一覧ファイル
|   |
|   |-- draft/      ... 未投稿記事ファイルのディレクトリ
|   |   |-- 編集日時_記事タイトル.md
|   |
|   |-- entry/      ... 投稿済み記事の保存ディレクトリ
|   |   |
|   |   |-- 12345678900000000(EntryID)
|   |   |   |-- 記事タイトル.md   (/ -> -になるよ)
|   |   |
|   |
|   |-- trash/      ... 投稿直前の記事バックアップディレクトリ
|   |   |
|   |   |-- 編集日時_記事のタイトル.md
|   |   |-- 12345678900000000(EntryID)
|   |   |   |-- 記事タイトル.md
```

${XDG_DATA_DIR}が未定義の場合は、`${HOME}/.local/share/hateblog/`配下に作るよ.


## Warning

### ブログの設定ファイルは公開しちゃダメ
はてなAtomPubのAPIキーが平文保存なのでそのまま公開しちゃダメ. 絶対.

別のナイスな方法があれば提案なり修正なりして下さいまし.

### 記事を投稿したら更新内容は確認してね
何かしらバグったときに、もしかすると投稿済みの記事の内容が空になったり、文字化けするような惨劇が起こるかもしない.  
不安ならブログの設定ファイルで`AUTO_BACKUP=ON`に設定しておこう.  
記事の投稿や削除、取得前のローカルの記事ファイルを、下のディレクトリに保存するようになるよ.  

- `${XDG_DATA_DIR}/hateblog/{BlogID}/trash/{EntryID}/記事タイトル.md`  ... 投稿済み記事
- `${XDG_DATA_DIR}/hateblog/{BlogID}/trash/編集日時_記事タイトル.md`   ... 下書き記事

バックアップで保持するのは1世代前だけだから注意してね.  
(古いバックアップファイルは削除してから新しいファイルを保存するよ)

### 文字コードの変換とかはやってない
ロケール設定に依存しちゃうと思う.  
きっとUTF-8じゃないとダメだと思う。

### 動作確認はFreeBSDでしかやってない
一応使う基本コマンドとかオプションなどはPOSIXの範囲で頑張ったつもりだけど、LinuxとかMacとかでちゃんと動くのかしら.

もしかするとMacとかは改行コードの変換が必要なのかも.  
何かおかしかったら教えて下さいな.  

### その他
そのうちISSUEに書くか対応するかもかも.

- `entry edit/delete`でローカルにファイルがあれば`fzf`でプレビューを見たい
- `entry fetch`は記事が増えれば増えるほど遅くなる仕様.
- `entry fetch -f`は、記事コレクションから記事ファイルを生成したい(今は1記事ずつgetリクエストを送っている)
- 一度公開した記事を下書きに戻すことができない(HTTP 400エラー). ブラウザからはできるのだからなんとかなるのかも.
- シグナル処理未対応(Ctrl-Cとかで一時ファイルとか残っちゃうかも)
- 終了ステータス未対応(今どうなっているか確認してないけどとりあえずヘルプどおりではないはず)
- 複数の記事選択による操作って、需要あるのかしら


## Contribution
curlなどの外部ツールに依存はしているけど、移植は楽にしたいと思っているよ.

だから他のUNIXコマンドや使うオプションなどは、POSIXで規定されたもので頑張っているよ.

もし既にPOSIXに準拠していない箇所や他の環境で使えない箇所を見つけたらご指摘下さいな.

ちなみに、`applib`ディレクトリ配下のコマンドPrefixの意味は下記だよ.

|Prefix|説明
|:----:|:--------------------------------------------------------------------------
|\_d   |変数などの定義
|\_e   |フィルタの終わり. stdinからデータを受け取りstdoutに出力しない. ファイルへ保存など.
|\_f   |フィルタ. stdinからデータを受け取りstdoutへ出力.
|\_s   |フィルタのはじまり. 引数などからデータを生成し、stdoutへデータを出力.
|\_m   |定型・共通処理. ちょっと曖昧だけど他に当てはまらない場合はこれにしてるはず.


## Licence

[MIT](https://github.com/hacolab/hateblog-sh/LICENCE)


## Author

[hacolab](https://github.com/hacolab)


