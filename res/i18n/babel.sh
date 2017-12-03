export PATH="~/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"
eval "$(source '/media/mint/85f78c06-a96e-4020-ac36-9419b7e456db/mint/root/tools/pyenv/3.6.1/venv/game/bin/activate')"
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

