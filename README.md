# EPub

一步一步学习如何制作一个EPub电子书阅读器。How to make a EPub e-book reader step by step.

目录说明：

- Explore EPub电子书阅读器的探索历程，包括对同类APP的分析以及一步步实现的小目标。
- Code 代码实现。


进度：

- 实现epub文件的解压和解析。
- 通过css分栏以及修改css和html实现章节的“分页”效果。


目前遇到的问题：

UIPageViewController本身和UIScrollView嵌套后会造成手势冲突而且非常难以控制，可以看我这个demo[UIPageViewControllerBug](https://github.com/ApesTalk/UIPageViewControllerBug)。当时做类似今日头条效果的时候一开始打算用UIPageViewController来做的，后来发现UI复杂的情况下问题太多了。后面调研发现今日头条使用UICollectionView来实现的，效果比较好。

后面抽时间会尝试用新的方式实现，敬请期待！
