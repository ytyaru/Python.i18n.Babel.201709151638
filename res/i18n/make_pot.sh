export PATH="~/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
echo "Pythonコマンド準備完了。"

SOURCE_CODE=../../src/main.py
DOMAIN_NAME=hello
mkdir -p ./po/
python pygettext.py ${SOURCE_CODE}
cp messages.pot ./po/${DOMAIN_NAME}_de.po
cp messages.pot ./po/${DOMAIN_NAME}_en.po
cp messages.pot ./po/${DOMAIN_NAME}_ja.po
mv messages.pot ./po/messages.pot
echo "対象ソースコード'${SOURCE_CODE}'からpotファイルを作成しました。"
echo "（ドメイン名は'${DOMAIN_NAME}'です。対象ソースコードに gettext.install('${DOMAIN_NAME}') のようにしてドメイン名を指定してください）"
#
# ( 手作業: poファイルに翻訳テキストを記入する )
#
echo "./po/配下にある各.poファイルに翻訳したテキストを入力してください。完了したらENTERキーを押下してください。"
read
mkdir -p ./languages/de/LC_MESSAGES
mkdir -p ./languages/en/LC_MESSAGES
mkdir -p ./languages/ja/LC_MESSAGES
python msgfmt.py ./po/${DOMAIN_NAME}_de.po
python msgfmt.py ./po/${DOMAIN_NAME}_en.po
python msgfmt.py ./po/${DOMAIN_NAME}_ja.po
mv ./po/${DOMAIN_NAME}_de.mo ./languages/de/LC_MESSAGES/${DOMAIN_NAME}.mo
mv ./po/${DOMAIN_NAME}_en.mo ./languages/en/LC_MESSAGES/${DOMAIN_NAME}.mo
mv ./po/${DOMAIN_NAME}_ja.mo ./languages/ja/LC_MESSAGES/${DOMAIN_NAME}.mo
echo "moファイルの作成と配置が完了しました。正常終了します。"

