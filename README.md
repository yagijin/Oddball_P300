# Oddball_P300
オドボール課題でP300を取得するためのプログラム（Programs to obtain P300 with Oddball Task）

# p300.m
以下のオドボール課題の刺激提示プログラムを使用して，取得したxdfファイルを読み込み，加算平均してプロットする

# OddballTaskPic.py  & OddballTaskSound.py
P300を誘発するためのオドボール課題実行用のプログラム，指定した間隔での刺激の提示と時間同期のためにLSLへの出力ができる.  
スペースを押すと実験開始，もう一度押すと途中で止められる，刺激の提示後もう一度押すと終了.  
LSLには，ターゲット刺激:[2]，スタンダード刺激:[1]，なにもない時:[0]を出力する.  

実験ごとに変更して使う変数は，コード上でまとめてあり以下の通り．

変数 | 内容
--- | ---
frameRate | タイマーのフレームレート(表示間隔)
printsec | 1刺激の表示時間
sumOfStimulus | 刺激の総数
ratioOfTarget | 刺激の総数に占めるターゲットの割合
targetPic or targetSound | ターゲット刺激のファイル名
standardPic or standardSound| スタンダード刺激のファイル名

