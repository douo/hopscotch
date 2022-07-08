# What

![](doc/screen_jumper_logo.png)

Hopscotch 是一款 macos 的小工具，它可以通过快捷键让鼠标光标在不同的屏幕之间跳动。

# Why

macos 实际有两种焦点：

- 一种是输入焦点，系统传递过来输入事件会通过焦点控件向上传播，直到被消费（想当然）
- 还有一种是屏幕焦点，表现为当前鼠标指针所在的屏幕，或者唤起 Spotlight 的屏幕

部分全局快捷键只会作用于处于焦点的屏幕。比如 Mission Control，也就是说 `^→`/`^←` ，只能切换当前焦点屏幕的全屏幕应用（空间），如果需要切换另一屏的应用，没有快捷键只能滑动一下鼠标来切换焦点屏幕。习惯于键盘操作的话，这个常见的场景需要切换一下鼠标其实是挺难忍的，这个小工具就是为了解决这个人痛点。

实际上之前有用 [@virushuo](https://twitter.com/virushuo) 的 [CatchMouse](http://blog.xiqiao.info/2011/06/12/catchmouse-icon%E5%8F%8Aweb-%E8%AE%BE%E8%AE%A1/) 来解决这个这个痛点，不过这个小工具只能通过编号切换显示器。对于这种场景还是有点别扭，我觉得还是上一个或下一个循环切换更符合直觉，所以便基于 swiftui 简单实现了类似的工具。

# How

![](doc/screen_jumper_intro.gif)

[下载](https://github.com/douo/hopscotch/releases/)

默认按键：

- `⇧⌃.` 切换下一个屏幕
- `⇧⌃,` 切换上一个屏幕
- `⇧⌃/` 切换到当前活跃（输入焦点）屏幕

所有快捷键皆可定制，也支持 CatchMouse 那样直接指定显示器切换。
