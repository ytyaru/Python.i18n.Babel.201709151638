# このソフトウェアについて

pybabelコマンドを半自動実行するshスクリプトを作った。

ついでにmsgidが重複したときの挙動を確認した。

# 前回

[pybabelを使ってみた](http://ytyaru.hatenablog.com/entry/2018/11/09/000000)。

# 今回

* pybabelコマンドを半自動実行するshスクリプトを作った
* msgidが重複したときの挙動を確認した

## shスクリプトを作成した

`./res/i18n/babel.sh`

* `py`→`pot`→(翻訳)→`po`→`mo`の生成をスクリプト化した
    * (翻訳とその入力は手作業である)
    * `po`が既存なら更新、未だ無いなら新規作成する
* `po`ファイル内をgrep検索して未翻訳箇所を表示する

いちいちコマンドや引数を確認しながら打つ必要がなくなる。

## msgidが重複したときの挙動を確認した

pybabelを使うと複数ファイルの`.py`から`.pot`を生成できる。ファイル内を見てみると全ファイルの`msgid`, `msgstr`がある。異なる`.py`ファイルにあったメッセージで、`msgid`が重複していたらどうなるのか。疑問に思ったので試してみた。

同じ`msgid`(MessageID)を使った場合、出力される`pot`ファイルの`msgstr`は1箇所だけ。コメントにファイルパスが複数書かれる。実行結果はその`msgid`に対応する`msgstr`に置き換えられるだけ。

# 実行

```sh
$ bash ./res/i18n/babel.sh
```

.shファイル内にはpyenv用のコードが含まれている。適時、自分の環境にあわせて修正すること。（pyenvを使っていないなら不要。使っているなら、Babelをインストールした仮想環境を指定する。必要に応じて使用するPythonのバージョンを指定する）

他、以下の点を任意に変更できる。

* `SOURCE_ROOT_DIR=../../src/`
* `DOMAIN=hello`
* `MO_ROOT_DIR=./languages`
* `LANGUAGES="de en ja"`

## 結果例

```sh
$ bash babel.sh 
Python 3.6.1
pybabel 2.5.1
Python, Babelコマンド準備完了。
extracting messages from ../../src/main.py
extracting messages from ../../src/sub.py
extracting messages from ../../src/mypackage/mymodule.py
writing PO template file to hello.pot
.pyファイルから.potファイルを生成しました。
updating catalog ./languages/de/LC_MESSAGES/hello.po based on hello.pot
updating catalog ./languages/en/LC_MESSAGES/hello.po based on hello.pot
updating catalog ./languages/ja/LC_MESSAGES/hello.po based on hello.pot
.potファイルから.poファイルを生成(更新)しました。
--------------------
./languages/de/LC_MESSAGES/hello.po-6-msgid ""
./languages/de/LC_MESSAGES/hello.po:7:msgstr ""
--
./languages/de/LC_MESSAGES/hello.po-22-msgid "MSG000"
./languages/de/LC_MESSAGES/hello.po:23:msgstr ""
--
./languages/de/LC_MESSAGES/hello.po-26-msgid "Good Luck !"
./languages/de/LC_MESSAGES/hello.po:27:msgstr ""
--
./languages/en/LC_MESSAGES/hello.po-6-msgid ""
./languages/en/LC_MESSAGES/hello.po:7:msgstr ""
--
./languages/en/LC_MESSAGES/hello.po-22-msgid "MSG000"
./languages/en/LC_MESSAGES/hello.po:23:msgstr ""
--
./languages/en/LC_MESSAGES/hello.po-26-msgid "Good Luck !"
./languages/en/LC_MESSAGES/hello.po:27:msgstr ""
--
./languages/ja/LC_MESSAGES/hello.po-6-msgid ""
./languages/ja/LC_MESSAGES/hello.po:7:msgstr ""
--
./languages/ja/LC_MESSAGES/hello.po-26-msgid "Good Luck !"
./languages/ja/LC_MESSAGES/hello.po:27:msgstr ""
--------------------
.poファイルにあるmsgstrが空値の箇所は以上です。翻訳して埋めてください。完了したらENTERキーを押下してください。

compiling catalog ./languages/de/LC_MESSAGES/hello.po to ./languages/de/LC_MESSAGES/hello.mo
compiling catalog ./languages/en/LC_MESSAGES/hello.po to ./languages/en/LC_MESSAGES/hello.mo
compiling catalog ./languages/ja/LC_MESSAGES/hello.po to ./languages/ja/LC_MESSAGES/hello.mo
moファイルの作成と配置が完了しました。終了します。
```

`grep`で翻訳テキストが未入力の箇所を表示している点がミソ。poファイルが未存なら新規作成、既存なら更新する。

## ソースコード

pybabelコマンドをうまいこと実行するスクリプト。

./res/i18n/babel.sh
```sh
export PATH="~/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
eval "$(source '/.../pyenv/3.6.1/venv/game/bin/activate')"
python -V
pybabel --version
echo "Python, Babelコマンド準備完了。"

SOURCE_ROOT_DIR=../../src/
DOMAIN=hello
pybabel extract -o "${DOMAIN}.pot" --input-dirs="${SOURCE_ROOT_DIR}"
echo ".pyファイルから.potファイルを生成しました。"

MO_ROOT_DIR=./languages
LANGUAGES="de en ja"
for lang_code in ${LANGUAGES}
do
MO_DIR=${MO_ROOT_DIR}/${lang_code}/LC_MESSAGES
if [ ! -e "${MO_DIR}/${DOMAIN}.po" ]; then
    #新規作成
    pybabel init -D ${DOMAIN} -l ${lang_code} -i "${DOMAIN}.pot" -d "${MO_ROOT_DIR}"
else
    #更新
    pybabel update -D ${DOMAIN} -l ${lang_code} -i "${DOMAIN}.pot" -d "${MO_ROOT_DIR}"
fi
done
echo ".potファイルから.poファイルを生成(更新)しました。"
echo "--------------------"
grep 'msgstr ""' ${MO_ROOT_DIR}/*/LC_MESSAGES/${DOMAIN}.po -n -B 1
echo "--------------------"
echo ".poファイルにあるmsgstrが空値の箇所は以上です。翻訳して埋めてください。完了したらENTERキーを押下してください。"
read

for lang_code in ${LANGUAGES}
do
MO_DIR=${MO_ROOT_DIR}/${lang_code}/LC_MESSAGES
if [ -e "${MO_DIR}/${DOMAIN}.po" ]; then
    #po→mo
    pybabel compile -D ${DOMAIN} -l ${lang_code} -i "${MO_DIR}/${DOMAIN}.po" -d "${MO_ROOT_DIR}"
else
    echo "ファイルが存在しないためmoファイルを作成できませんでした。: ${MO_DIR}/${DOMAIN}.po"
fi
done
echo "moファイルの作成と配置が完了しました。終了します。"
```

# 課題

* `.py`ソースコードの更新日時をみて、反映漏れをなくしたい＆必要な分だけ実行したい
    * コードが更新されたら即座に必ず`po`ファイルに反映したい
* `.py`ソースコードの更新日時をみて、必要な分だけ実行したい
    * 数秒間の時間を要するので短縮したい
* 未翻訳箇所はテキストエディタでそこを表示するようにしたい
    * 画面表示をみてファイラとテキストエディタを手動操作して修正箇所へたどりつく手続きが面倒
        * そもそも翻訳とそのテキスト入力も自動化したい

# 開発環境

* Linux Mint 17.3 MATE 32bit
* [pyenv](https://github.com/pylangstudy/201705/blob/master/27/Python%E5%AD%A6%E7%BF%92%E7%92%B0%E5%A2%83%E3%82%92%E7%94%A8%E6%84%8F%E3%81%99%E3%82%8B.md) 1.0.10
    * Python 3.6.1
* [pygettext.py](https://github.com/python/cpython/blob/6f0eb93183519024cb360162bdd81b9faec97ba6/Tools/i18n/pygettext.py)
* [msgfmt.py](https://github.com/python/cpython/blob/6f0eb93183519024cb360162bdd81b9faec97ba6/Tools/i18n/msgfmt.py)

# ライセンス

* https://sites.google.com/site/michinobumaeda/programming/pythonconst

Library|License|Copyright
-------|-------|---------
[Babel](https://github.com/python-babel/babel)|[BSD 3-clause](https://github.com/python-babel/babel/blob/master/LICENSE)|[Copyright (C) 2013 by the Babel Team, see AUTHORS for more information.](https://github.com/python-babel/babel/blob/master/LICENSE)
