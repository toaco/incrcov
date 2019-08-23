# IncrCov 

生成两个Commit之间修改的代码的增量测试覆盖率报告

## 背景

随着项目越来越大，全量覆盖率无法有效的判断新增代码自测完成度，因此开发了这款增量测试覆盖率汇报工具

## 示例

**上一个提交**

```ruby
1: class Demo
2:   def say_hello
3:     puts 'hello'
4:   end
5: end
```

执行测试(需要安装[SimpleCov](https://github.com/colszowka/simplecov))：

```ruby
RSpec.describe Demo do
  it "say hello" do
    Demo.new.say_hello
  end
end
```

**当前提交**

```ruby
01: class Demo
02:   def say_hello
03:     puts 'Hello' # change 'hello' to 'Hello'
04:   end
05: 
06:   def say_world
07:     puts 'world'
08:   end
09: end
```

使用incrcov生成增量测试覆盖率汇报：

```powershell
$ incrcov HEAD^ HEAD
+----------------+-----------+-------------+---------------+---------------+--------------+
| Path           | Method    | Total Lines | Covered Lines | Coverage Rate | Missed Lines |
+----------------+-----------+-------------+---------------+---------------+--------------+
| app/demo2.rb:6 | say_world | 2           | 1             | 50.0%         | 7            |
+----------------+-----------+-------------+---------------+---------------+--------------+
Overall incremental test coverage: 75.0%
Number of updated methods: 2
Number of low test coverage(<90%) methods: 1
```

- 表格会所有修改的方法中，测试覆盖率没有达到90%的方法
- `Overall incremental test coverage` 表示所有被修改的方法，一共有75%的行都被测试覆盖到了
- `Number of updated methods` 表示一共修改了2个方法
- `Number of low test coverage(<90%) methods` 表示覆盖率没有达到90%的方法，数量等于表格里的行数

## 安装

```bash
gem install specific_install
gem specific_install git@github.com:toaco/incrcov.git
```

## 用法

汇报两个Commit之间修改的代码的增量测试覆盖率：`incrcov <commit1> <commit2>`, commit的格式和Git的格式完全兼容，如：

- 比较当前提交和上一个提交： `incrcov HEAD^ HEAD` 或 `incrcov HEAD~1 HEAD`
- 比较当前分支和develop分支：  `incrcov develop HEAD`
- 比较develop分支和master分支：`incrcov mastar develop`
- 比较本地develop分支和上游develop分支：`incrcov upstream/develop  develop`

### Markdown格式支持

默认输出的报告适合在控制台直接展示。除此之外，只是生成Markdown格式的报告，可直接将结果粘贴到GitLab或者Github的PR中去，生成Markdown需要使用`--format`参数，示例如下：

- `incrcov master develop -fmd`
- `incrcov master develop -f md`
- `incrcov master develop --format md`

生成的报告如下:

### Merge Request Incremental Test Coverage Report 👀

- Overall incremental test coverage: 75.0%
- Number of updated methods: 2
- Number of low test coverage(<90%) methods: 1

---

|Path|Method|Total Lines|Covered Lines|Coverage Rate|Missed Lines|
|:-|:-|:-|:-|:-:|:-:|
|app/demo2.rb:6|say_world|2|1|50.0%|7|




