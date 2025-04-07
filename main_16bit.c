#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_STRARG_NUM 128

char roboks[] =
    "    w\\\n"
    "     \\          y>/一<\\w\n"
    "      \\         y/ヽ_ノヽw\n"
    "       \\           yﾊw\n"
    "        \\       c———————w\n"
    "         \\.  c／         ＼w\n"
    "           c／  w●c       w●c  ＼w\n"
    "          c/     w❘ニニニ❘c     c\\w\n"
    "        c／|—————————————————|ヽw\n"
    "       c/ /b|    g〇 y〇 m〇     b|ヽヽw\n"
    "     r(一) b|                 | r(一)w\n"
    "          b|     y／一＼      b|\n"
    "          b|     y| ?  |      b|\n"
    "          b|     y＼一／      b|\n"
    "          b|＿  ＿＿＿＿  ＿.|\n"
    "             cΠ         Π   \n"
    "        r(ニニ|         |ニニ)d)\n";

// 文字列の長さを計算
int str_length(const char *str) {
    int len = 0;
    while (*str != '\0') {
        len += 1;
        str++;
    }
    return len;
}

// 指定された長さの横棒を表示
void print_bar(int len) {
    printf("  ");
    for (int i = 0; i < len + 2; i++) {
        printf("-");
    }
    printf("\n");
}

// 吹き出し表示
void say_bubble(const char *str) {
    int len = str_length(str);
    print_bar(len);
    printf("＜ %s ＞\n", str);
    print_bar(len);
}

// ANSI エスケープシーケンスで色を設定
void set_color(char c) {
    switch (c) {
        case 'c': printf("\x1b[36m"); break; // シアン
        case 'y': printf("\x1b[33m"); break; // 黄色
        case 'w': printf("\x1b[37m"); break; // 白
        case 'r': printf("\x1b[31m"); break; // 赤
        case 'g': printf("\x1b[32m"); break; // 緑
        case 'b': printf("\x1b[34m"); break; // 青
        case 'd': printf("\x1b[39m"); break; // デフォルト
        case 'm': printf("\x1b[35m"); break; // 紫
        default: break;
    }
}

int main(int argc, char **argv) {
    const char *default_str = "踏めば助かるのに...";
    char *str = NULL;
    char argbuf[MAX_STRARG_NUM];

    // コマンドライン引数の処理
    for (int i = 1; i < argc; i++) {
        strcpy(argbuf, argv[i]);
        str = argbuf;
    }

    if (str == NULL) {
        str = (char *)default_str;
    }

    // 吹き出し表示
    say_bubble(str);

    // AA を色付きで出力
    char *roboks_ptr = roboks;
    while (*roboks_ptr != '\0') {
        if (*roboks_ptr == 'c' || *roboks_ptr == 'y' || *roboks_ptr == 'w' ||
            *roboks_ptr == 'r' || *roboks_ptr == 'g' || *roboks_ptr == 'b' ||
            *roboks_ptr == 'd' || *roboks_ptr == 'm') {
            set_color(*roboks_ptr); // 色変更
        } else {
            printf("%c", *roboks_ptr); // 通常の文字を表示
        }
        roboks_ptr++;
    }

    // 色をリセット
    printf("\x1b[0m\n");

    return 0;
}
