<template>
  <router-view />
</template>

<style>
* { margin: 0; padding: 0; box-sizing: border-box; }
html, body, #app { height: 100%; }
body { font-family: 'Helvetica Neue', Helvetica, 'PingFang SC', 'Microsoft YaHei', Arial, sans-serif; background: #f0f3f8; }

/* ========== 文档 1.2.4 全局 UI 标准化（审美升级） ========== */
.el-card {
  border-radius: 12px;
  border: 1px solid #e7ebf2;
  box-shadow: 0 1px 4px rgba(31, 74, 126, 0.04) !important;
}
.el-card.is-hover-shadow:hover { box-shadow: 0 8px 24px rgba(31, 111, 235, 0.10) !important; }
.el-card__header { font-weight: 600; color: #2c3e50; padding: 14px 18px; border-bottom: 1px solid #eef1f6; }

/* 页面标题条 */
.page-header {
  display: flex; align-items: center; gap: 10px;
  margin-bottom: 14px; padding: 0 2px;
}
.page-header .ph-icon {
  width: 30px; height: 30px; border-radius: 8px;
  background: linear-gradient(135deg, #1f6feb, #4e9bff);
  color: #fff; display: flex; align-items: center; justify-content: center; font-size: 15px;
}
.page-header h3 { font-size: 16px; color: #23324e; font-weight: 700; }
.page-header .ph-sub { font-size: 12px; color: #94a3b8; }

/* 筛选操作区（顶部三层布局第一层） */
.toolbar {
  display: flex; gap: 10px; align-items: center; flex-wrap: wrap;
  background: #f6f9fd; border: 1px solid #e7ebf2; border-radius: 10px;
  padding: 10px 12px; margin-bottom: 14px;
}

/* 按钮 */
.el-button { border-radius: 8px; transition: all 0.18s ease; font-weight: 500; }
.el-button:not(.is-link):hover { transform: translateY(-1px); box-shadow: 0 4px 12px rgba(31, 111, 235, 0.18); }
.el-button--primary { background: linear-gradient(135deg, #1f6feb, #3a8bff); border: none; }
.el-button--success { background: linear-gradient(135deg, #22b573, #2fd07f); border: none; }
.el-button--warning { background: linear-gradient(135deg, #f59e0b, #fbbf24); border: none; }
.el-button--danger { background: linear-gradient(135deg, #ef4444, #f87171); border: none; }

/* 表格 */
.el-table { border-radius: 10px; overflow: hidden; }
.el-table th.el-table__cell {
  background: linear-gradient(180deg, #f2f6fc, #eaf1fa) !important;
  color: #3d5673 !important; font-weight: 600; letter-spacing: 0.2px;
}
.el-table--striped .el-table__body tr.el-table__row--striped td { background: #f7faff; }
.el-table .el-table__row:hover td { background: #eef6ff !important; }

/* 弹窗 */
.el-dialog { border-radius: 14px; box-shadow: 0 16px 48px rgba(15, 42, 80, 0.18); }
.el-dialog__header { border-bottom: 1px solid #eef1f6; padding-bottom: 14px; }
.el-dialog__title { font-weight: 700; color: #23324e; }

/* 表单 */
.el-input__wrapper, .el-textarea__inner, .el-select__wrapper { border-radius: 8px; }
.el-form-item__label { font-weight: 500; color: #4a5875; }

/* 分页 */
.el-pagination { justify-content: flex-end; margin-top: 4px; }

/* 标签/Tag */
.el-tag { border-radius: 6px; }
</style>