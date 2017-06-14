# GSForm
simple but powerful lib for Form


### 1.主要特点
**轻量级，只有4个类，1个控制器```Controller```，3个视图模型```ViewModel```**
支持** iOS8 及以上 **

[GitHub 和 Demo 下载](https://github.com/beforeold/GSForm)

1. 支持完全自定义单元格```cell```类型
- 支持自动布局```Autolayout```和固定行高
- 表单每行```row```数据和事件整合为一个```model```，基本只需管理```row```
- 积木式组合 ```row```，支持 ```section``` 和 ```row``` 的隐藏，易于维护
- 支持传入外部数据
- 支持快速提取数据
- 支持参数的最终合法性校验
- 支持数据模型的类型完全自由自定义，可拆可合
- 支持设置```row```的白名单和黑名单及权限管理

### 2.背景

通常，将一个页面需要编辑/录入多项信息的页面称为“表单页面”，以下称**表单**，以某注册页面为例：

![某注册页面](http://upload-images.jianshu.io/upload_images/73339-4224623071ef5884.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
在移动端进行表单的录入设计本身因为录入效率低，是尽量避免的，但对于特定的业务场景还是有存在的情况。通常基于 UITableView 进行开发，内容多有文本输入、日期（或者其他PickerView）、各类自定义的单元格```cell```（比如包含 UISwitch、UIStepper等）、以及一些需要前往二级页面获取信息后回调等元素。

表单的麻烦在于行与行之间数据往往没有特定的规律，上图中第二组数据中，姓名、性别、出生日期以及年龄，4个不同的 cell  则是 4个完全不同的交互方式来录入数据，依照传统的 UITableView 的代理模式来处理，有几个弊端： 
- 在实现数据源方法 ```tableView:cellForRowAtIndexPath:```难免要对每一个 indexPath 进行 switch-case 处理，
- 糟糕的是对于每一行的点击事件，```tableView:didSelectRowAtIndexPath:````方法，也要进行 switch-case 判断
- 因为 cell 的重用关系，每一行数据的取值也将严重依赖具体的 indexPath，数据的获取变得困难，同样地，编辑变化后的信息也需要存到到数据模型中，对于跳转二级页面回调的数据需要更新数据后要反过来刷新对应的```cell```。
- 根据不同的入口，有一些 row 可能不存在或者需要临时插入 cell，这使得写死 indexPath 的 switch-case 很不可靠
- 即便是静态页面的 cell，写死了 indexPath 进行 switch-case 在未来的需求调整时（比如调整了 row 的位置，新增/减少了某些 row），变得难以维护。

### 3.解决方案
- 回顾上面的弊端，很大的一个弊病在于严重的依赖了 row 的位置 indexPath 来获取数据、绘制 cell、处理 cell 的事件以及回调刷新 row，借助 MVVM 的思路，将每一行的视图类型、视图刷新以及事件处理由每一行各自处理，用 GSRow 对象进行管理。
- 单元格的构造，基于运行时和block，通过运行时构建cell，利用 row 对象的 cellClass/nibName 属性分别从代码或者 xib 加载可重用的 cell 视图备用
- 调用 GSRow 的 configBlock 进行cell 内容的刷新和配置（包括了 cell内部的block回调事件）

```Objective-C
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GSRow *row = [self.form rowAtIndexPath:indexPath];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:row.reuseIdentifier];
    if (!cell) {
        if (row.cellClass) {
            /// 运行时加载
            cell = [[row.cellClass alloc] initWithStyle:row.style reuseIdentifier:row.reuseIdentifier];
        } else {
          /// xib 加载
            cell = [[[NSBundle mainBundle] loadNibNamed:row.nibName owner:nil options:nil] lastObject];
        }
        /// 额外的视图初始化
        !row.cellExtraInitBlock ?: row.cellExtraInitBlock(cell, row.value, indexPath);
    }
    
    NSAssert(!(row.rowConfigBlockWithCompletion && row.rowConfigBlock), @"row config block 二选一");
    
    GSRowConfigCompletion completion = nil;
    if (row.rowConfigBlock) {
        /// cell 的配置方式一：直接配置
        row.rowConfigBlock(cell, row.value, indexPath);
        
    } else if (row.rowConfigBlockWithCompletion) {
        /// cell 的配置方式二：直接配置并返回最终配置 block 在返回cell前调用（可用作权限管理）
        completion = row.rowConfigBlockWithCompletion(cell, row.value, indexPath);
    }
    
    [self handleEnableForCell:cell gsRow:row atIndexPath:indexPath];
    
    /// 在返回 cell 前做最终配置（可做权限控制）
    !completion ?: completion();
    
    return cell;
}
```
- 一个分组可以包含多个 GSRow 对象，在表单中对分组的头尾部视图并没有高度定制和复杂的事件回调，因此暂不做高度封装，主要提供作为 Row 的容器以及整体隐藏使用，即GSSection。

```Objective-C
@interface GSSection : NSObject

@property (nonatomic, strong, readonly) NSMutableArray <GSRow *> *rowArray;
@property (nonatomic, assign, readonly) NSUInteger count;
@property (nonatomic, assign) CGFloat headerHeight;
@property (nonatomic, assign) CGFloat footerHeight;
@property (nonatomic, assign, getter=isHidden) BOOL hidden;

`- (void)addRow:(GSRow *)row;
`- (void)addRowArray:(NSArray <GSRow *> *)rowArray;

@end
```
- 同理，多个 GSSetion 对象在一个容器内进行管理会更便利，设置 GSForm 作为整个表单的容器，从而数据结构为GSForm 包含多个 GSSection，而 GSSection 包含多个 GSRow，这样与 UITableView 的数据源和代理结构保持一致。

```Objective-C
@interface GSForm : NSObject

@property (nonatomic, strong, readonly) NSMutableArray <GSSection *> *sectionArray;
@property (nonatomic, assign, readonly) NSUInteger count;

@property (nonatomic, assign) CGFloat rowHeight;

- (void)addSection:(GSSection *)section;
- (void)removeSection:(GSSection *)section;

- (void)reformRespRet:(id)resp;
- (id)fetchHttpParams;

- (NSDictionary *)validateRows;

/// 配置全局禁用点击事件的block
@property (nonatomic, copy) id(^disableBlock)(GSForm *);

/// 根据 indexPath 返回 row
- (GSRow *)rowAtIndexPath:(NSIndexPath *)indexPath;
/// 根据 row 返回 indexPath
- (NSIndexPath *)indexPathOfGSRow:(GSRow *)row;

@end
```
为了承载和实现 UITableView 的协议，将 UITabeView 作为控制器的子视图，设为 GSFormVC，GSFormVC 同时是 UITableView 的数据源dataSource 和代理 delegate，负责将 UITableView 的重要协议方法分发给 GSRow 和 GSSection，以及黑白名单控制，如此，具体的业务场景下，通过继承 GSFormVC 配置 GSForm 的结构，即可实现主体功能，对于分组section的头尾视图等可以通过在具体业务子类中实现 UITableView 的方式来实现即可。

### 4.具体功能点的实现
#### 4.1 支持完全自定义单元格 cell
当 UITableView 的 tableView:cellForRowAtIndexPath:方法调用时，第一步时通过 row 的 reuserIdentifer 获取可重用的cell，当需要创建cell 时通过 GSRow 配置的 cellClass 属性或者 nibName 属性分别通过运行时或者 xib 创建新的cell 实例，从而隔离对 cell类型的直接依赖。
其中 GSRow 的构造方法

```Objective-C
- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier;

```
接着配置 cell 的具体类型，cellClass 或者 nibName 属性
```Objective-C
@property (nonatomic, strong) Class cellClass;
@property (nonatomic, strong) NSString *nibName;

```

为了在 cell 初始化后可以进行额外的子视图构造或者样式配置，设置 GSRow 的 cellExtraInitBlock，将在 首次构造 cell 时进行额外调用，属性的声明：

```Objective-C
@property (nonatomic, copy) void(^cellExtraInitBlock)(id cell, id value, NSIndexPath *indexPath); 
// if(!cell) { extraInitBlock };

```

下面是构造 cell 的处理
```Objective-C
    GSRow *row = [self.form rowAtIndexPath:indexPath];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:row.reuseIdentifier];
    if (!cell) {
        if (row.cellClass) {
            cell = [[row.cellClass alloc] initWithStyle:row.style reuseIdentifier:row.reuseIdentifier];
        } else {
            cell = [[[NSBundle mainBundle] loadNibNamed:row.nibName owner:nil options:nil] lastObject];
        }
        
        !row.cellExtraInitBlock ?: row.cellExtraInitBlock(cell, row.value, indexPath);
    }

```
获取到构造的可用的cell 后需要利用数据模型对 cell 的内容进行填入处理，这个操作通过配置```rowConfigBlock``` 或者 ```rowConfigBlockWithCompletion``` 属性完成，这两个属性只会调用其中一个，后者的区别时会在配置完成后返回一个 block 变量用于进行最终配置，属性的声明如下：

```Objective-C
@property (nonatomic, copy) void(^rowConfigBlock)(id cell, id value, NSIndexPath *indexPath); 
// config at cellForRowAtIndexPath:
@property (nonatomic, copy) GSRowConfigCompletion(^rowConfigBlockWithCompletion)(id cell, id value, NSIndexPath *indexPath); 
// row config at cellForRow with extra final config
```

#### 4.2 支持自动布局```AutoLayout```和固定行高
自 iOS8 后 UITableView 支持高度自适应，通过在 GSFormVC 内对 TableView 进行自动布局的设置后，再在各个 Cell 实现各自的布局方案，表单的布局思路可以兼容固定行高和自动布局，TableView 的配置:
```
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.estimatedRowHeight = 88.f;
    }
    
    return _tableView;
}
```
对应地，GSRow 的 rowHeight 属性可以实现 cell高度的固定，如果不传值则默认为自动布局，属性的声明:

```Objective-C
@property (nonatomic, assign) CGFloat rowHeight;
```
进而在 TableView 的代理中实现 cell 的高度布局，如下：
```
- (CGFloat)tableView:(UITableView *)tableView
        heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    GSRow *row = [self.form rowAtIndexPath:indexPath];
    
    return row.rowHeight == 0 ? UITableViewAutomaticDimension : row.rowHeight;
}
```
#### 4.3 表单每行row数据和事件整合为一个model，基本只需管理row
为了方便行数据的存储，设置了专门用于存值的属性，根据实际的需要进行赋值和取值即可，声明如下：

```Objective-C
@property (nonatomic, strong) id value;
```
在实际的应用中，value 使用可变字典的场景居多，如果内部有特定的自定义类对象，可以用一个key值保存在可变字典value中，方便存取，value 作为可变字典使用时有极大的自由便利性，可以在其中保存有规律的信息，比如表单cell 左侧的 title，右侧的内容等等，因为 block 可以时分便利地捕获上下对象，而且 GSForm 的设计实现时一个 GSRow 的几乎所有信息都在一个代码块内实现，从而实现上下文的共享，在上一个block存值时的key，可以在下一个block方便地得知用于取值和设值，比如一个 GSRow 的配置：

```Objective-C
- (GSRow *)rowForTrace {
      GSRow *row = nil;
    
    GSTTraceListRespRet *model = [[GSTTraceListRespRet alloc] init];
    row = [[GSRow alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GSLabelFieldCell"];
    row.cellClass = [GSLabelFieldCell class];
    row.rowHeight = 44;
    row.value = @{kCellLeftTitle:@"跟踪方案"}.mutableCopy;
    row.value[kCellModelKey] = model;
    row.rowConfigBlock = ^(GSLabelFieldCell *cell, id value, NSIndexPath *indexPath) {
        cell.leftlabel.text = value[kCellLeftTitle];
        cell.rightField.text = model.name;
        cell.rightField.enabled = NO;
        cell.rightField.placeholder = @"请选择运输跟踪方案";
        cell.accessoryView = form_makeArrow();
    };    
    
    WEAK_SELF
    row.reformRespRetBlock = ^(GSTGoodsOriginInfoRespRet *ret, id value) {
        model.trace_id = ret.trace_id;
        model.name = ret.trace_name;
    };
    
    row.didSelectBlock = ^(NSIndexPath *indexPath, id value) {
        STRONG_SELF
        GSTChooseTraceVC *ctl = [[GSTChooseTraceVC alloc] init];
        ctl.chooseBlock = ^(GSTTraceListRespRet *trace){
            model.trace_id = trace.trace_id;
            model.name = trace.name;
            [strongSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        };
        [strongSelf.navigationController pushViewController:ctl animated:YES];
    };
  return row;
}
```
对于需要在点击 row 时跳转二级页面的情况，通过配置 GSRow 的 ```didSelectBlock``` 来实现，声明及示例如下：
```Objective-C
@property (nonatomic, copy) void(^didSelectCellBlock)(NSIndexPath *indexPath, id value, id cell); 
// didSelectRow with Cell

    row.didSelectBlock = ^(NSIndexPath *indexPath, id value) {
        STRONG_SELF
        GSTChooseTraceVC *ctl = [[GSTChooseTraceVC alloc] init];
        ctl.chooseBlock = ^(GSTTraceListRespRet *trace){
            model.trace_id = trace.trace_id;
            model.name = trace.name;
            [strongSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        };
        [strongSelf.navigationController pushViewController:ctl animated:YES];
    };
```
通过对该属性的配置，在 TableView 的代理方法 tableView:didSelectRowAtIndexPath: 来调用：

```Objective-C
- (void)tableView:(UITableView *)tableView
         didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    GSRow *row = [self.form rowAtIndexPath:indexPath];
    !row.didSelectBlock ?: row.didSelectBlock(indexPath, row.value);
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    !row.didSelectCellBlock ?: row.didSelectCellBlock(indexPath, row.value, cell);
}

```
综上，通过多个属性的配合使用，基本达成了 cell 的构造、配置和 cell内部事件以及 cell 整体点击事件的整合。

#### 4.4 积木式组合 row，支持 section 和 row 的隐藏，易于维护
基于每行数据及其事件整合在 GSRow 内，具备了独立性，通过根据需求整合到不同的 GSSection 后即可搭建成具体的业务页面，举例：

```Objective-C
/// 构造页面的表单数据
- (void)buildDataSource {
    [self.form addSection:[self sectionChooseProject]];
    [self.form addSection:[self sectionTransportSettings]];
    [self.form addSection:[self sectionUploadAddress]];
    [self.form addSection:[self sectionDownloadAdress]];
    [self.form addSection:[self sectionOtherInfo]];
}
```
此外，GSSection/GSRow 都支持隐藏，根据不同的场景设置 GSSection/GSRow 的隐藏状态，可以动态设置表单。
```Objective-C
@property (nonatomic, assign, getter=isHidden) BOOL hidden;
```
隐藏属性将通过 UITableView 的数据源 dataSource 协议方法决定是否显示 section/row:

```Objective-C
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger count = 0;
    for (GSSection *section in self.form.sectionArray) {
        if(!section.isHidden) count++;
    }
    
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    GSSection *fSection = self.form[section];
    NSInteger count = 0;
    for (GSRow *row in fSection.rowArray) {
        if(!row.isHidden) count++;
    }
    
    return count;
}

```
也正是因为GSSection/GSRow 的隐藏特点，根据 indexPath 取值时不能单方面地根据索引从数组中取值，也应考虑到是否有隐藏的对象，为此在 GSForm 定义了两个工具方法，用于关联 indexPath 与 GSRow 对象，在必要时调用。

```Objective-C
/// 根据 indexPath 返回 row
- (GSRow *)rowAtIndexPath:(NSIndexPath *)indexPath;
/// 根据 row 返回 indexPath
- (NSIndexPath *)indexPathOfGSRow:(GSRow *)row;
```
通过这些可组合性，可以便利地搭建页面，且易于增删或者调整顺序。

#### 4.5 支持传入外部数据
有些编辑类型的表单，首次加载时通过其他渠道加载数据后先填入一部分值，为此，GSRow 设计了从外部取值的属性 reformRespRetBlock，而外部参数经由 GSForm 进行遍历调用。

```Objective-C
///GSForm
/// 传入外部数据
- (void)reformRespRet:(id)resp;
- (void)reformRespRet:(id)resp {
    for (GSSection *section in self.sectionArray) {
        for (GSRow *row in section.rowArray) {
            !row.reformRespRetBlock ?: row.reformRespRetBlock(resp, row.value);
        }
    }
}
/// GSRow 从外部取值的block配置
@property (nonatomic, copy) void(^reformRespRetBlock)(id ret, id value);    
 // 外部传值处理
```
如此，通过网络请求的数据返回后调用 GSForm 将数据分发到 GSRow 存入到各自的 value 后，刷新 TableView 即可实现外部数据的导入，比如网络请求后调用构建页面各个 GSRow 并 传入外部数据:

```Objective-C

SomeHTTPModel *result; // 网络请求成功返回值
self.result = result;
[self buildForm];
[self.form reformRespRet:result];
[self.tableView reloadData];
```

#### 4.6 支持快速提取数据
对应地，当数据录入完成后，点击提交时，需要获取各行数据进行网络请求，此时根据业务场景各自通过，通过每个 GSRow 配置各自的请求参数即可，声明配置请求参数的属性 httpParamConfigBlock，以从表单中提取一个字典参数为例：
声明:
```Objective-C
@property (nonatomic, copy) id(^httpParamConfigBlock)(id value); 
// get param for http request
```
从表单中获取请求参数:
```Objective-C
/// 获取当前请求参数
- (NSMutableDictionary *)fetchCurrentRequestInfo {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    for (GSSection *secion in self.form.sectionArray) {
        if (secion.isHidden) continue;
        
        for (GSRow *row in secion.rowArray) {
            if (row.isHidden || !row.httpParamConfigBlock) continue;
            
            id http = row.httpParamConfigBlock(row.value);
            if ([http isKindOfClass:[NSDictionary class]]) {
                [dic addEntriesFromDictionary:http];
            } else if ([http isKindOfClass:[NSArray class]]) {
                for (NSDictionary *subHttp in http) {
                    [dic addEntriesFromDictionary:subHttp];
                }
            }
        }
    }
    return dic;
}

```
#### 4.7 支持参数的最终合法性校验
一般地，对用户输入的参数在提交前需要进行合法性校验，对于较长的表单而言通常是点击提交按钮时进行，对参数的最终合法性进行逐个校验，当参数不合法时进行提醒，将合法性校验的要求声明为 GSRow 的属性进行处理，如下：

```Objective-C
/// check isValid
@property (nonatomic, copy) NSDictionary *(^valueValidateBlock)(id value);
```
返回值为字典，其中字典的内容并不严格限制，一个好的实践是：用一个key 标记校验是否通过，另外一个key标记校验失败的提醒，比如：

```Objective-C
    row.valueValidateBlock = ^id(id value) {
        // 校验失败，返回一个 key 为 @NO 的字典，并携带错误地址。
        if(![value[kCellModelKey] count]) return rowError(@"XX时间不可为空");
    
        return rowOK(); // 返回一个 key 为 @YES 的字典
    };
```
如此，可由整个表单 GSForm发起整体校验，做遍历处理，举例如下：

```Objective-C
/// GSForm
- (NSDictionary *)validateRows;
- (NSDictionary *)validateRows {
    for (GSSection *section in self.sectionArray) {
        for (GSRow *row in section.rowArray) {
            if (!row.isHidden && row.valueValidateBlock) {
                NSDictionary *dic = row.valueValidateBlock(row.value);
                NSNumber *ret = dic[kValidateRetKey];
                NSAssert(ret, @"必须有结果参数");
                if (!ret) continue;
                if (!ret.boolValue) return dic;
            }
        }
    }
    
    return rowOK();
}

// 业务方的使用
/// 检查参数合法性，如不合法冒泡提醒
- (BOOL)validateParameters {
    NSDictionary *validate = [self.form validateRows];
    if (![validate[kValidateRetKey] boolValue]) {
        NSString *msg = validate[kValidateMsgKey]; // 错误提示信息
        [GSProgressHUD showWithTitle:msg inView:self.view];
        return NO;
    }
    return YES;
}

```

#### 4.8 支持数据模型的类型完全自由自定义，可拆可合
某一行的业务数据可以独立存在 GSRow 的value中，也可以直接使用 控制器外部的属性/实例变量，根据实际的情况便利性决定；
同理，在配置请求参数时，也可以根据网络层设计的需要决定，如果是配置一个自定义Model，则事先在外部声明懒加载一个请求参数，在  httpConfigBlock 中对应属性进行设值，如果是配置一个 字典，则可以独立提供一个 字典又或者干脆对外部的一个可变字典设值。

#### 4.9 支持设置row的白名单和黑名单及权限管理
在特定的场景下，只能编辑个别cell，这些可以编辑的cell应加入**白名单**；在另外一个特定的场景下，不能编辑个别cell，这些不能编辑的cell应加入**黑名单**，在白黑名单之上，可能还夹杂一些特定权限的控制，使得只有特定权限时才可以编辑。针对这类需求，通过在 cell 视图上层覆盖一个可操作性拦截按钮进行处理，通过配置 GSRow 的 enableValidateBlock 和 disableValidateBlock 属性进行实现。

```Objective-C
/// GSForm
/// 传入此值实现全局禁用，此时点击事件的 block 
@property (nonatomic, copy) id(^disableBlock)(GSForm *);


/// GSRow 的黑名单
@property (nonatomic, copy) NSDictionary *(^disableValidateBlock)(id value, BOOL didClick);
/// GSRow的白名单
@property (nonatomic, copy) NSDictionary *(^enableValidateBlock)(id value, BOOL didClick);
```

### 延伸
经过在项目中的应用，这个框架基本成型，并具备相当高的定制能力和灵活性，在后续的功能开发上会进一步迭代。
以下是几个注意点：
- 在一些 cell 不规则/规则的静态页面，也适合使用。
- 此框架处处都是 block 的应用，因此应格外注意避免循环引用的发生，因为 控制器持有 GSForm 和 UITableView，所以在 GSRow 的 block 属性配置，以及内部 GSRow配置 cell 的 cellConfigBlock 内又有 cell.textChangeBlock 这类情况，需要进行双重的弱引用处理，比如：

```Objective-C
    WEAK_SELF
    row.rowConfigBlock = ^(GSTCodeScanCell *cell, id value, NSIndexPath *indexPath) {
        STRONG_SELF
        cell.textChangeBlock = ^(NSString *text){
            value[kCellRightContent] = text;
        };
        
        /// 因为 cell 的block 是 强引用，所以这类需要再次设置弱引用。
        __weak typeof(strongSelf) weakWeakSelf = strongSelf; 
        cell.scanClickBlock = ^(){
            GSQRCodeController *scanVC = [[GSQRCodeController alloc] init];
            scanVC.returnScanBarCodeValue = ^(NSString *str) {
                value[kCellRightContent] = str;
                [weakWeakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            };
            [weakWeakSelf.navigationController pushViewController:scanVC animated:YES];
        };
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    };
```
- 此外也有许多其他方案可供学习：


1. 最常提及的 [XLForm@Github](https://github.com/xmartlabs/XLForm)。
- [简书J_Knight](http://www.jianshu.com/u/3dd433cb3ea1)前不久的[基于MVVM，用于快速搭建设置页，个人信息页的框架]。(http://www.jianshu.com/p/1f89513f3fb1)
- [@靛青K](http://weibo.com/DianQK?refer_flag=1001030101_&is_all=1) 的 [iOS 上基于 RxSwift 的动态表单填写](http://t.cn/RXDsB9Z)。

### 分享
[GitHub 和 Demo 下载](https://github.com/beforeold/GSForm)

[个人博客](http://www.jianshu.com/u/7fb183d40a56)

欢迎你加入我的圈子讨论。
![](http://upload-images.jianshu.io/upload_images/73339-bdd16427cf564214.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
