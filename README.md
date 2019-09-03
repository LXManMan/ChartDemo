# ChartDemo
折线图简单使用


```
 _chartView =[[LineChartView alloc]initWithFrame:CGRectMake(10, 0, ScreenWidth -20, SCREEN_HEIGHT - 200)];
    [self.view addSubview:_chartView];
    _chartView.delegate = self;
    _chartView.chartDescription.enabled = NO;
    _chartView.dragEnabled = YES;
    [_chartView setScaleEnabled:NO];
    _chartView.pinchZoomEnabled = NO;
    _chartView.drawGridBackgroundEnabled = YES;

    _chartView.xAxis.gridLineDashLengths = @[@10.0, @10.0];
    _chartView.xAxis.gridLineDashPhase = 0.f;
    //Y轴设置
    ChartYAxis *leftAxis = _chartView.leftAxis;
    [leftAxis removeAllLimitLines];
    leftAxis.axisMaximum = 120.0; //最大值
    leftAxis.axisMinimum = -0.0; //最小值
    leftAxis.gridLineDashLengths = @[@5.f, @5.f];
    leftAxis.drawZeroLineEnabled = NO;
    leftAxis.drawLimitLinesBehindDataEnabled = YES;
    leftAxis.inverted = NO;//是否翻转
    //Y轴上数据格式
    leftAxis.valueFormatter = [[SymbolsValueFormatter alloc]init];
    leftAxis.labelPosition = YAxisLabelPositionOutsideChart;//label位置
    leftAxis.labelTextColor = [UIColor blackColor];//文字颜色
    leftAxis.labelFont = [UIFont systemFontOfSize:10.0f];//文字字体
    leftAxis.gridColor = [UIColor grayColor];//网格线颜色
    leftAxis.gridAntialiasEnabled = NO;//开启抗锯齿
    _chartView.rightAxis.enabled = NO;

    //X轴设置
    ChartXAxis *xAxis = _chartView.xAxis;
    xAxis.granularityEnabled = YES;//设置重复的值不显示
    xAxis.labelPosition= XAxisLabelPositionBottom;//设置x轴数据在底部
    xAxis.gridColor = [UIColor clearColor];
    xAxis.labelTextColor = [UIColor blackColor];//x轴上文字颜色
    xAxis.axisLineColor = [UIColor redColor];
    //X轴上数据格式
    xAxis.valueFormatter = [[DateValueFormatter alloc]init];

    _chartView.legend.form = ChartLegendFormLine;

    ChartViewPortHandler *scaleX = _chartView.viewPortHandler;

    [scaleX setMinimumScaleX:1.5f];//只滑动不缩放：（系统内部默认是先缩放后滑动）及初始化时x轴就缩放1.5倍,就可以滑动了，
    [_chartView animateWithXAxisDuration:2.5];

    ```


   ```
    //每一条线代表一条dataSet
    LineChartDataSet *set1 = nil;
    if (_chartView.data.dataSetCount > 0)
    {
        set1 = (LineChartDataSet *)_chartView.data.dataSets[0];
        [set1 replaceEntries: values];
        [_chartView.data notifyDataChanged];
        [_chartView notifyDataSetChanged];
    }
    else
    {
        //折线数据填充
        set1 = [[LineChartDataSet alloc] initWithEntries:values label:@"第一条折线"];
        set1.valueFormatter =[[SetValueFormatter alloc]initWithArr:values];
        set1.mode = LineChartModeCubicBezier;//平滑曲线
        set1.drawIconsEnabled = NO;
        set1.lineDashLengths = @[@5.f, @2.5f];
        set1.highlightLineDashLengths = @[@5.f, @2.5f];
        [set1 setColor:UIColor.blackColor];//线条颜色
        [set1 setCircleColor:UIColor.redColor];//圆圈的颜色
        set1.lineWidth = 1.0;
        set1.circleRadius = 8.0;
        set1.circleHoleRadius = 4;//小圆半径
        set1.circleHoleColor =  UIColor.blueColor;//小圆颜色
        set1.drawCircleHoleEnabled = YES;//是否绘制小圆
        set1.valueFont = [UIFont systemFontOfSize:9.f];//曲线上valulLabel的大小
        
        //最下方第一条折线的设置
        set1.formLineDashLengths = @[@5.f, @2.5f];
        set1.formLineWidth = 1.0;
        set1.formSize = 15.0;
        
        //渐变色设置
        NSArray *gradientColors = @[
                                    (id)[ChartColorTemplates colorFromString:@"#00ff0000"].CGColor,
                                    (id)[ChartColorTemplates colorFromString:@"#ffff0000"].CGColor
                                    ];
        CGGradientRef gradient = CGGradientCreateWithColors(nil, (CFArrayRef)gradientColors, nil);
        
        set1.fillAlpha = 1.0f;
        set1.fill = [ChartFill fillWithLinearGradient:gradient angle:90.f];
        set1.drawFilledEnabled = YES;
        CGGradientRelease(gradient);
        NSMutableArray *dataSets = [[NSMutableArray alloc] init];
        [dataSets addObject:set1];
        
        LineChartData *data = [[LineChartData alloc] initWithDataSets:dataSets];
        
        //赋予chartView数据
        _chartView.data = data;
   ```
![image](https://github.com/LXManMan/ChartDemo/blob/master/MyDemo/WX20190903-152816%402x.png)
