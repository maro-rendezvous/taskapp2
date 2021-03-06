import RealmSwift

class Category: Object {
    // 管理用 ID。プライマリーキー
    @objc dynamic var categoryId = 0

    // カテゴリ名
    @objc dynamic var categoryName = ""

    // id をプライマリーキーとして設定
    override static func primaryKey() -> String? {
        return "categoryId"
    }
}
