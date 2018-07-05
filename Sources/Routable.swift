//
//  Router.swift
//  Router
//
//  Created by BigL on 2017/3/21.
//  Copyright © 2017年 fun.bigl.com. All rights reserved.
//

import UIKit
import FHXRoutableAssist

public class Routable: NSObject {
  /// 类名前缀
  @objc public static var classPrefix = "Router_"
  /// 方法名前缀
  @objc public static var funcPrefix = "router_"
  /// 参数名
  @objc public static var paramName = "Params"
  /// 指定协议头, ""则为任意格式
  @objc public static var scheme = ""
  
  /// 命名空间
  static let namespace = Bundle.main.infoDictionary?["CFBundleExecutable"] as! String
  /// 重定向策略 (可用于页面降级)
  static var repleRules = [String: URLValue]()
  /// 缓存
  static var cache = [String: RoutableData]()
  /// 回调缓存
  static var blockCache = [String: (_: [String: Any])->()]()
}

// MARK: - block
extension Routable {
  
  /// 执行回调
  ///
  /// - Parameters:
  ///   - id: 回调id(自动生成并传递)
  @objc public class func callback(id:String) {
    callback(id: id, params: [:], isRemove: true)
  }
  
  /// 执行回调
  ///
  /// - Parameters:
  ///   - id: 回调id(自动生成并传递)
  ///   - params: 回调数据
  @objc public class func callback(id:String, params:[String: Any]) {
    callback(id: id, params: params, isRemove: true)
  }
  
  /// 执行回调
  ///
  /// - Parameters:
  ///   - id: 回调id(自动生成并传递)
  ///   - params: 回调数据
  ///   - isRemove: 是否移除本次回调(默认移除)
  @objc public class func callback(id:String, params:[String: Any],isRemove: Bool) {
    blockCache[id]?(params)
    if isRemove { blockCache[id] = nil }
  }
  
  
}

extension Routable {
  
  /// 执行路径指定函数
  ///
  /// - Parameter url: 函数路径
  @objc public class func exec(url: URL, params:[String: Any] = [:]) {
    _ = object(url: url, params: params)
  }
  
  /// 执行路径指定函数
  ///
  /// - Parameter url: 函数路径
  @objc public class func exec(str: String, params:[String: Any] = [:]) {
    _ = object(str: str, params: params)
  }
  
  /// 通知所有已缓存类型函数
  ///
  /// - Parameter url: 函数路径
  @objc public class func notice(url: URL,params:[String: Any] = [:]) {
    notice(str: url.absoluteString, params: params)
  }
  
  /// 通知所有已缓存类型函数
  ///
  /// - Parameter url: 函数路径
  @objc public class func notice(str: String,params:[String: Any] = [:]) {
    guard let url = createURL(url: str, params: params) else { return }
    guard var value = urlParse(url: url) else { return }
    if value.targetName != "notice" { return }
    for item in cache.values {
      value.targetName = item.targetName
      _ = target(urlValue: value, block: nil)
    }
  }
  
}

// MARK: - UIKit
public extension Routable {
  
  /// 解析viewController类型
  ///
  /// - Parameter url: viewController 路径
  /// - Returns: viewController 或者 nil
  @objc public class func viewController(url: URL,params:[String: Any] = [:]) -> UIViewController? {
    return object(url: url, params: params) as? UIViewController
  }
  
  /// 解析viewController类型
  ///
  /// - Parameter url: viewController 路径
  /// - Returns: viewController 或者 nil
  @objc public class func viewController(str: String,params:[String: Any] = [:]) -> UIViewController? {
    return object(str: str, params: params) as? UIViewController
  }
  
  /// 解析view类型
  ///
  /// - Parameter url: view 路径
  /// - Returns: view 或者 nil
  @objc public class func view(url: URL,params:[String: Any] = [:]) -> UIView? {
    return object(url: url, params: params) as? UIView
  }
  
  /// 解析view类型
  ///
  /// - Parameter url: view 路径
  /// - Returns: view 或者 nil
  @objc public class func view(str: String,params:[String: Any] = [:]) -> UIView? {
    return object(str: str, params: params) as? UIView
  }
}

extension Routable {
  
  /*
   [待重定向URL: 重定向URL + 参数名替换(可选)]
   ["http://a/vc": "http://b/vc?errorPage=a&type=$style"] // host重定向
   URL:
   http://a/vc?style=0
   替换后:
   http://b/vc?errorPage=a&type=0
   ["http://a/vc": "http://web/vc?url=https://www.baidu.com"] //页面降级
   */
  
  /// 设置重定向规则组
  /// 
  /// - Parameter rules: 重定向规则
  @objc public class func rewrite(rules: [String: String]) {
    repleRules.removeAll()
    rules.forEach { (item) in
      if let lhsURL = URL(string: item.key),
        let rhsURL = URL(string: item.value),
        let lhsValue = urlParse(url: lhsURL),
        let cacheId = getCacheId(value: lhsValue),
        let rhsValue = urlParse(url: rhsURL) {
        repleRules[cacheId] = rhsValue
      }
    }
  }
  
  /// 解析Any类型(回调形式)
  ///
  /// - Parameters:
  ///   - url: url
  ///   - params: url 参数(选填)
  ///   - call: 回调数据
  @discardableResult @objc public class func object(str: String,
                                                    params:[String: Any] = [:],
                                                    call: ((_: [String: Any])->())? = nil) -> Any? {
    guard let url = createURL(url: str, params: params) else { return nil }
    guard let value = urlParse(url: url) else { return nil }
    let rewriteValue = rewrite(value: value)
    return target(urlValue: rewriteValue, block: call)
  }
  
  /// 解析Any类型(回调形式)
  ///
  /// - Parameters:
  ///   - url: url
  ///   - params: url 参数(选填)
  ///   - call: 回调数据
  @discardableResult @objc public class func object(url: URL,
                                                    params:[String: Any] = [:],
                                                    call: ((_: [String: Any])->())? = nil) -> Any? {
    return object(str: url.absoluteString, params: params, call: call)
  }
  
}

extension Routable {
  
  class func getCacheId(value: Routable.URLValue) -> String? {
    let id = value.targetName + "#" + value.selName
    if id.first == "#" || id.last == "#" { return nil }
    return id
  }
  
  /// 清除指定缓存
  ///
  /// - Parameter name: key
  public class func cacheAll() {
    cache.removeAll()
  }
}
