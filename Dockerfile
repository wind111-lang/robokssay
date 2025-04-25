FROM ubuntu:24.04 AS robokssay

RUN apt -y update && apt -y upgrade
RUN apt install -y build-essential

RUN mkdir /src
COPY main.c /src

WORKDIR /src
RUN gcc main.c -o robokssay
RUN cp robokssay /usr/bin

CMD robokssay

FROM --platform=linux/amd64 ubuntu:22.04 AS robokssay-16bit

# 必要なパッケージのインストールと Snap 有効化
RUN apt-get update && apt-get install -y \
    software-properties-common \
    snapd \
    wget \
    curl \
    unzip \
    lhasa \
    locales \
    gnupg2 && \
    rm -rf /var/lib/apt/lists/*

# Snap のパスを通す（Docker 内で snap コマンドを使えるように）
ENV PATH="/snap/bin:${PATH}"

# dosbox-x を Snap 経由でインストール
RUN snap install dosbox-x

# ia16-elf-gcc のための PPA を追加してインストール
RUN add-apt-repository -y ppa:tkchia/build-ia16 && \
    apt-get update && \
    apt-get install -y gcc-ia16-elf && \
    rm -rf /var/lib/apt/lists/*


# 作業ディレクトリを作成
WORKDIR /src

# Cファイルをコピーし、IA-16 GCCでコンパイル
COPY main_16bit.c .
RUN mkdir -p /dos && ia16-elf-gcc -march=i286 -o /dos/robokssay.com main_16bit.c

# ===== 日本語フォント（VGON16）取得と展開 =====
RUN cd /dos && \
    wget -O VGON16.LZH http://web.archive.org/web/20160929103053/http://homepage3.nifty.com/silo/FONTV/VGON16.LZH && \
    lha x VGON16.LZH && cp vgon16/*.tlf . && rm -rf VGON16.LZH vgon16

# ===== AUTOEXEC.BAT を作成して自動実行設定 =====
RUN echo "@ECHO OFF" > /dos/AUTOEXEC.BAT && \
    echo "SET LANG=JA" >> /dos/AUTOEXEC.BAT && \
    echo "SET TZ=JST-9" >> /dos/AUTOEXEC.BAT && \
    echo "MODE CON CODEPAGE PREPARE=((932) C:\\DOS\\EGA.CPI)" >> /dos/AUTOEXEC.BAT && \
    echo "MODE CON CODEPAGE SELECT=932" >> /dos/AUTOEXEC.BAT && \
    echo "KEYB JP,932,C:\\DOS\\KEYBOARD.SYS" >> /dos/AUTOEXEC.BAT && \
    echo "robokssay.com" >> /dos/AUTOEXEC.BAT

# ===== DOSBox-X 設定ファイルの作成（VGA + DOS/V + 日本語フォント + 自動実行） =====
RUN echo '[dosbox]' > /etc/dosbox-x.conf && \
    echo 'machine=svga_s3' >> /etc/dosbox-x.conf && \
    echo '' >> /etc/dosbox-x.conf && \
    echo '[dosv]' >> /etc/dosbox-x.conf && \
    echo 'dosvtype=dosv' >> /etc/dosbox-x.conf && \
    echo 'dosvfont=/dos/GONWN16.TLF' >> /etc/dosbox-x.conf && \
    echo '' >> /etc/dosbox-x.conf && \
    echo '[autoexec]' >> /etc/dosbox-x.conf && \
    echo 'mount C /dos' >> /etc/dosbox-x.conf && \
    echo 'C:' >> /etc/dosbox-x.conf && \
    echo 'AUTOEXEC.BAT' >> /etc/dosbox-x.conf && \
    echo 'exit' >> /etc/dosbox-x.conf

# ===== 実行（CLIベースの DOSBox-X） =====
ENTRYPOINT ["dosbox-x", "-conf", "/etc/dosbox-x.conf"]
