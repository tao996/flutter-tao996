// 1. 查询条件构建器类
class QueryBuilder<T> {
  final List<String> _conditions = [];
  final List<Object?> _args = [];

  QueryBuilder<T> where(String field, String operator, dynamic value) {
    _conditions.add('$field $operator ?');
    _args.add(value);
    return this;
  }

  QueryBuilder<T> andWhere(String field, String operator, dynamic value) {
    if (_conditions.isNotEmpty) _conditions.add('AND');
    return where(field, operator, value);
  }

  (String, List<Object?>) build() {
    return (_conditions.join(' '), _args);
  }
}