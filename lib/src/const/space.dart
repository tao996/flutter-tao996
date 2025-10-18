// 约定基础间距单位
class MySpace {
  // 基础单位：4.0 是一个很好的选择，因为它适用于 4-point 或 8-point 网格系统
  static const double unit = 4.0;

  // ----------------------------------------------------
  // 核心间距常量 (使用清晰的语义化命名)
  // ----------------------------------------------------

  // Extra Small (XS) - 相当于 1 * unit
  static const double xs = unit; // 4.0

  // Small (S) - 相当于 2 * unit
  static const double s = 2 * unit; // 8.0

  // Medium (M) - 相当于 4 * unit (这是 8-point 系统中的基础单位 8.0/16.0)
  static const double m = 4 * unit; // 16.0

  // Large (L) - 相当于 6 * unit 或 8 * unit
  static const double l = 6 * unit; // 24.0

  // Extra Large (XL)
  static const double xl = 8 * unit; // 32.0

  // XXL
  static const double xxl = 12 * unit; // 48.0

  // ----------------------------------------------------
  // 特定组件或场景使用的常量
  // ----------------------------------------------------

  // 页面边缘标准 Padding
  static const double screenPadding = 4 * unit; // 16.0

  // Icon Size (大/中/小)
  static const double iconSizeSmall = 5 * unit; // 20.0
  static const double iconSizeMedium = 6 * unit; // 24.0

  static const double rowLeftText = 25 * unit;
}

// 为任何数字类型 (int, double) 添加一个属性来计算间距
extension SpaceMultiplier on num {
  /// 计算基于 AppSpace.unit (4.0) 的间距值
  double get space => this * MySpace.unit;
}
