
To add a new language, use as layout of  '/podemo_empty.po' and fill all the msgstr "" with the translation.

When done, rename the file with the code of your language after the "_" , like 'podemo_xz.po'.

You may also add the translation of the new language name at end of each .po file (not obligatory).
Example add this at end of of the po files:

msgid "Mylanguage [xz]"
msgstr "MyTranslatedLanguage [xz]"

When your .po file is ready, just add it into '/yourapp/lang/' folder.

The .po file is loaded after each switch of language so you may change the content of the .po when you want.

Non need to recompile the application.

