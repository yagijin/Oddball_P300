# -*- coding: utf-8 -*-

#OddballTask.py
#by J.Yagi 2019/06/03 
#P300を誘発するためのオドホール課題実行用のプログラム，指定した間隔での刺激の提示と時間同期のためにLSLへの出力ができる
#スペースを押すと実験開始，スペースを押すと途中で止められる，刺激の提示後スペースで終了
#LSLには，ターゲット刺激:[2]，スタンダード刺激:[1]，なにもない時:[0]を出力する

import sys
import random
from time import perf_counter as pc                                         # 高精度のタイマ
from pylsl import StreamInfo, StreamOutlet                                  #Python用のLSLライブラリ

from PyQt5.QtWidgets import QApplication, QDesktopWidget, QLabel, QWidget   #GUI用のライブラリ
from PyQt5.QtGui import QPainter, QColor, QFont, QPen, QPixmap
from PyQt5.QtCore import Qt, QTimer, QRectF, pyqtSignal

####################################################################
##この部分の値を適宜変更して使ってください．
####################################################################
frameRate = 10                      #タイマーのフレームレート(表示間隔)
printsec = 1                        #1刺激の表示時間
sumOfStimulus = 10                  #刺激の総数
ratioOfTarget = 0.2                 #刺激の総数に占めるターゲットの割合
targetPic = "stimulus/blue.png"     #ターゲット刺激のファイル名
standardPic = "stimulus/red.png"    #スタンダード刺激のファイル名
####################################################################

class Stimulus:
    def __init__(self,stimulusOrder):
        self.on = 0                 #LSLに出力する提示刺激の状態
        self.stimulusOrder = stimulusOrder
        self.counterStimulus = 0
        self.next_time = pc() + printsec

    def resetTimer(self):
        self.next_time = pc() + printsec

    def draw(self, ctime):
        painter = QPainter(window)

        if (self.on == 1) or (self.on == 2):
            if self.stimulusOrder[self.counterStimulus] == 0: 
                pic = QPixmap(targetPic)                    #画像の読み込み
                painter.drawPixmap(75,75,pic)               #画像の描画　（int,int, ->：画像の表示開始地点

            elif self.stimulusOrder[self.counterStimulus] == 1:
                pic = QPixmap(standardPic)
                painter.drawPixmap(75,75,pic)

        if ctime >= self.next_time:                         #刺激を一定時間ごとに切り替えるための処理
            self.next_time += printsec
            if (self.on == 1) or (self.on == 2):
                #print(pc()) # コメントアウトを外せば，時間をコンソールに表示できる
                self.counterStimulus = self.counterStimulus + 1
                self.on = 0
                print(self.counterStimulus)                 #何刺激目か表示
            else:
                if self.stimulusOrder[self.counterStimulus] == 0:
                    self.on = 1
                elif self.stimulusOrder[self.counterStimulus] == 1:
                    self.on = 2

class MainWindow(QWidget):
    
    def __init__(self):
        super().__init__()
        print("###  [Space] to Start and Pause/Unpause  ###")
        self.base_time = pc()
        self.OrderStimulus()
        self.initStimulus()
        self.initUI()
        self.show()
        info = StreamInfo('Oddballstimulus', 'stimulation', 1, 100, 'float32', 'oddballstimu20190531')
        self.outlet = StreamOutlet(info)

    def initUI(self):
        self.setWindowTitle("Oddball-Task Stimulus")
    
        self.timer = QTimer(self)
        self.timer.timeout.connect(self.update)             #updateでpaintEventメソッドを更新

    #割合が決まった刺激をランダムに並び替えたリストを作るメソッド
    def OrderStimulus(self):         
        self.stimulusOrder = list()                         #作成するリスト

        sumOfTarget =  int(sumOfStimulus*ratioOfTarget)

        for i in range(sumOfTarget):
            self.stimulusOrder.append(0)
        for i in range(sumOfStimulus-sumOfTarget):
            self.stimulusOrder.append(1)

        random.shuffle(self.stimulusOrder)                  #要素をシャッフル

    # 刺激を定義するメソッド
    def initStimulus(self):
        self.stim = Stimulus(self.stimulusOrder)

    #キーが押される度に実行されるメソッド
    def keyPressEvent(self, e):                            
        if e.key() == Qt.Key_Space:
            if (self.stim.counterStimulus >= sumOfStimulus):#終了するときのキー操作
                self.timer.start()
                sys.exit()
            elif self.timer.isActive():                     #実行途中で止めるときのキー操作
                self.timer.stop()
            else:                                           #実行途中で再開するときのキー操作
                self.stim.resetTimer()
                self.timer.start(frameRate)                 #frameRateは，いらないかも

    #updateされるたびに実行されるメソッド
    def paintEvent(self, QPaintEvent):      
        curr_time = pc()
        if (self.stim.counterStimulus >= sumOfStimulus): #stim.~でclass Stimulus側（１つのインスタンス）の値を持ってこれる
            print("###  [Space] to Exit from This App  ###")
            self.timer.stop()
        else:
            self.stim.draw(curr_time)
            stimu = [int(self.stim.on)]      
            self.outlet.push_sample(stimu)
            #print(stimu) #コメントアウトを外せば，LSLに出力する値を確認できる

if __name__ == '__main__':
    app = QApplication(sys.argv)
    window = MainWindow()                                   #MainWindowのインスタンスを生成
    window.resize(700, 700)                                 #画面サイズを変更できる
    sys.exit(app.exec_())

