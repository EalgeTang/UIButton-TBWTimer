# UIButton-TBWTimer
使用分类实现了计时按钮的功能。能够缓存计时器状态，做到用户返回界面定时器接着上次的时间继续处理工作的功能。
能够更好的做到功能分离。并且想要从项目中抽离也可以变得很方便
如果只是需要一般的计时功能 可以如下例所示




[self.securityCodeBtn tbw_starTimerWithTotalSecond:60 isSaveTimerStateWithCacheKey:nil];





如果需要自定义 计时中 按钮的展示样式 可以如下


            [self.securityCodeBtn tbw_didChangeBlock:^NSAttributedString *(UIButton *btn, NSInteger second) {
                return [weakSelf setSecurityCodeButtonTextWithSecond:second];
            }];
            
            
            
            
          - (NSAttributedString *)setSecurityCodeButtonTextWithSecond:(NSInteger)sec
      {
            NSString *string = [NSString stringWithFormat:@"重新获取 %zdS",sec];
            NSMutableAttributedString *attribute = [[NSMutableAttributedString alloc] initWithString:string];
            NSDictionary *dic1 = @{NSForegroundColorAttributeName: RGBAColor(255, 255, 255, 0.5)};
            NSDictionary *dic2 = @{NSForegroundColorAttributeName: RGBColor(255, 255, 255)};
            NSDictionary *fontDic = @{NSFontAttributeName: [UIFont sx_systemFontWithSize:12.f]};
            [attribute addAttributes:dic1 range:NSMakeRange(0, 4)];
            NSUInteger length = [NSString stringWithFormat:@"%zdS",sec].length;
            [attribute addAttributes:dic2 range:NSMakeRange(5, length)];
            [attribute addAttributes:fontDic range:NSMakeRange(0, string.length)];
           return attribute;
    }



而如果希望定时器能够缓存状态， 在每次进入界面的时候都能够继续之前的工作。你需要指定一个key 并在第一次开始计时器工作的时候传给计时器



       [weakSelf.securityCodeBtn tbw_starTimerWithTotalSecond:60 isSaveTimerStateWithCacheKey:@"timer"];



并且在viewWillAppear 中如下方示例中做的那样，保证每次进入界面都能让计时器去检索状态



       [self.securityCodeBtn tbw_keepTheTimerStateWhenTheLastTimeisNotComplete:60 cacheKey:@"timer"];



