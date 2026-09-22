// ignore_for_file: file_names

import 'package:flutter/material.dart';

///添加用户弹窗中单行输入组件
///
///用于用户输入姓名、年龄、电话、邮箱、备注等信息
///
///组件负责标签、必填星号、输入框以及底部的分割线

class AddUserTextField extends StatelessWidget {
  const AddUserTextField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.required = false,
    this.keyboardType,
    this.obscureText = false,
  });

  /// 输入项名称，例如“姓名”。
  final String label;

  /// 输入框未填写时显示的提示文字。
  final String hintText;

  /// 输入控制器由弹窗主体创建和释放。
  final TextEditingController controller;

  /// 是否显示红色必填星号。
  final bool required;

  /// 控制弹出的键盘类型。
  final TextInputType? keyboardType;

  /// 是否为密码输入框（会隐藏输入内容）。
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      height: 46,
      child: DecoratedBox(
        ////////分割线
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0x10ffffff), width: 0.5),
          ),
        ),
        child: Row(
          children: [
            ///标签
            _buildLabel(),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: controller,
                keyboardType: keyboardType,
                obscureText: obscureText,
                textAlign: TextAlign.end, //输入框内容右对齐
                textAlignVertical: TextAlignVertical.center, //输入框内容垂直居中***
                cursorColor: const Color(0xFF1464DF), //光标颜色
                style: const TextStyle(fontSize: 18, color: Colors.white),
                decoration: InputDecoration(
                  isDense: true, //输入框内容垂直居中***
                  hintText: hintText,
                  hintStyle: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF8B909A),
                  ),
                  border: InputBorder.none, //输入框无边框
                  enabledBorder: InputBorder.none, //输入框无边框
                  focusedBorder: InputBorder.none, //输入框无边框
                  contentPadding: EdgeInsets.zero, //输入框内容内边距为0
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ////创建标签和必填星号可选项
  ///
  ///根据required参数判断是否显示红色必填星号
  ///如果required为true，则显示星号
  ///如果required为false，则不显示星号
  ///
  Widget _buildLabel() {
    return Text.rich(
      TextSpan(
        text: label,
        children: [
          if (required)
            const TextSpan(
              text: ' *',
              style: TextStyle(fontSize: 18, color: Color(0xFFF65151)),
            ),
        ],
      ),
      style: const TextStyle(fontSize: 18, color: Colors.white),
    );
  }
}
