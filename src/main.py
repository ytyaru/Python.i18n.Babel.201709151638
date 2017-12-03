#!python3.6
import gettext
import pathlib
import sub
import mypackage.mymodule
langPath = str(pathlib.Path('../res/i18n/languages').resolve())
gettext.install('hello', langPath)
#print(_('Hello World !!'))
print(_('MSG000'))

langs = ['ja', 'en', 'de']
lang = 'ja'
while lang:
    print(f'言語コードを入力してください(未入力+Enterで終了) {langs}: ', end='')
    lang = input()
    if lang not in langs: continue
    l = gettext.translation('hello', langPath, languages=[lang])
    l.install()
    print(sub.get_message_goodbye())
#    print(_('Welcome i18n !!'))
#    print(mypackage.mymodule.get_message_goodluck())

#print(sub.get_message_goodbye())
