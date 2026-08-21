<template>
  <div class="page">
    <div class="page-header">
          <div class="ph-icon">教</div>
          <div><h3>教务教学</h3></div>
        </div>
    <el-tabs v-model="tab">
      <el-tab-pane label="课程配置" name="course">
        <el-card shadow="never">
          <div class="toolbar">
            <el-button type="success" :icon="Plus" @click="openCourse">新增课程</el-button>
          </div>
          <el-table :data="courses" border stripe>
            <el-table-column prop="courseName" label="课程名称" width="140" />
            <el-table-column prop="subjectCode" label="学科" width="90" />
            <el-table-column label="类型" width="110">
              <template #default="{ row }">{{ courseTypeName(row.courseType) }}</template>
            </el-table-column>
            <el-table-column prop="periodsWeek" label="周课时" width="80" />
            <el-table-column prop="credit" label="学分" width="70" />
            <el-table-column prop="gradeId" label="年级ID" width="80" />
          </el-table>
        </el-card>
      </el-tab-pane>
      <el-tab-pane label="课表" name="schedule">
        <el-card shadow="never">
          <div class="toolbar">
            <el-button type="success" :icon="Plus" @click="openSchedule">新增课表条目</el-button>
          </div>
          <el-table :data="schedules" border stripe size="small">
            <el-table-column prop="weekday" label="星期" width="70" />
            <el-table-column prop="sectionNo" label="节次" width="60" />
            <el-table-column prop="courseId" label="课程ID" width="80" />
            <el-table-column prop="teacherId" label="教师ID" width="80" />
            <el-table-column prop="classId" label="班级ID" width="80" />
            <el-table-column prop="room" label="教室" width="120" />
            <el-table-column prop="startWeek" label="起始周" width="80" />
            <el-table-column prop="endWeek" label="结束周" width="80" />
          </el-table>
        </el-card>
      </el-tab-pane>
      <el-tab-pane label="考试与成绩" name="exam">
        <el-card shadow="never">
          <div class="toolbar">
            <el-button type="success" :icon="Plus" @click="openExam">新建考试</el-button>
            <el-select v-model="examFilter" placeholder="选择考试" clearable style="width: 240px" @change="loadScores">
              <el-option v-for="e in exams" :key="e.id" :label="e.examName" :value="e.id" />
            </el-select>
          </div>
          <el-table :data="exams" border stripe size="small" style="margin-bottom: 12px">
            <el-table-column prop="examName" label="考试名称" min-width="180" />
            <el-table-column label="类型" width="100">
              <template #default="{ row }">{{ examTypeName(row.examType) }}</template>
            </el-table-column>
            <el-table-column prop="examDate" label="考试日期" width="110" />
            <el-table-column prop="totalScore" label="总分" width="80" />
            <el-table-column label="状态" width="90">
              <template #default="{ row }">{{ { draft: '编排中', ongoing: '进行中', scoring: '录分中', finished: '已归档' }[row.status] || row.status }}</template>
            </el-table-column>
          </el-table>
          <el-table :data="scores" border stripe size="small">
            <el-table-column prop="studentId" label="学生ID" width="80" />
            <el-table-column prop="score" label="分数" width="90" />
            <el-table-column prop="gradeLevel" label="等级" width="80" />
            <el-table-column prop="classRank" label="班级排名" width="90" />
            <el-table-column prop="gradeRank" label="年级排名" width="90" />
          </el-table>
        </el-card>
      </el-tab-pane>
      <el-tab-pane label="教学纪实" name="teaching">
        <el-card shadow="never">
          <div class="toolbar">
            <el-button type="success" :icon="Plus" @click="openTeaching">新增纪实</el-button>
          </div>
          <el-table :data="teachingList" border stripe size="small">
            <el-table-column prop="teachDate" label="日期" width="110" />
            <el-table-column prop="classId" label="班级ID" width="80" />
            <el-table-column prop="courseId" label="课程ID" width="80" />
            <el-table-column prop="content" label="教学内容" min-width="220" show-overflow-tooltip />
            <el-table-column prop="classPerformance" label="课堂表现" min-width="140" show-overflow-tooltip />
          </el-table>
        </el-card>
      </el-tab-pane>
    </el-tabs>

    <el-dialog v-model="courseDlg.visible" title="课程" width="460px">
      <el-form label-width="90px">
        <el-form-item label="课程名称"><el-input v-model="courseDlg.form.courseName" /></el-form-item>
        <el-form-item label="学科编码"><el-input v-model="courseDlg.form.subjectCode" /></el-form-item>
        <el-form-item label="课程类型">
          <el-select v-model="courseDlg.form.courseType" style="width: 100%">
            <el-option label="必修" value="required" /><el-option label="选修" value="elective" />
            <el-option label="社团拓展" value="club" /><el-option label="中考核心" value="exam_core" />
            <el-option label="高考学科" value="gaokao" />
          </el-select>
        </el-form-item>
        <el-form-item label="年级ID"><el-input-number v-model="courseDlg.form.gradeId" :min="1" /></el-form-item>
        <el-form-item label="周课时"><el-input-number v-model="courseDlg.form.periodsWeek" :min="0" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="courseDlg.visible = false">取消</el-button>
        <el-button type="primary" @click="saveCourse">保存</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="examDlg.visible" title="新建考试" width="460px">
      <el-form label-width="90px">
        <el-form-item label="考试名称"><el-input v-model="examDlg.form.examName" /></el-form-item>
        <el-form-item label="考试类型">
          <el-select v-model="examDlg.form.examType" style="width: 100%">
            <el-option v-for="t in examTypes" :key="t.value" :label="t.label" :value="t.value" />
          </el-select>
        </el-form-item>
        <el-form-item label="年级ID"><el-input-number v-model="examDlg.form.gradeId" :min="1" /></el-form-item>
        <el-form-item label="考试日期"><el-date-picker v-model="examDlg.form.examDate" type="date" value-format="YYYY-MM-DD" style="width: 100%" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="examDlg.visible = false">取消</el-button>
        <el-button type="primary" @click="saveExam">创建</el-button>
      </template>
    </el-dialog>

    <el-dialog v-model="scheduleDlg.visible" title="课表条目" width="500px">
      <el-form label-width="90px">
        <el-row :gutter="12">
          <el-col :span="12"><el-form-item label="星期"><el-input-number v-model="scheduleDlg.form.weekday" :min="1" :max="7" /></el-form-item></el-col>
          <el-col :span="12"><el-form-item label="节次"><el-input-number v-model="scheduleDlg.form.sectionNo" :min="1" /></el-form-item></el-col>
          <el-col :span="12"><el-form-item label="课程ID"><el-input-number v-model="scheduleDlg.form.courseId" :min="1" /></el-form-item></el-col>
          <el-col :span="12"><el-form-item label="教师ID"><el-input-number v-model="scheduleDlg.form.teacherId" :min="1" /></el-form-item></el-col>
          <el-col :span="12"><el-form-item label="班级ID"><el-input-number v-model="scheduleDlg.form.classId" :min="1" /></el-form-item></el-col>
          <el-col :span="12"><el-form-item label="教室"><el-input v-model="scheduleDlg.form.room" /></el-form-item></el-col>
          <el-col :span="12"><el-form-item label="起始周"><el-input-number v-model="scheduleDlg.form.startWeek" :min="1" /></el-form-item></el-col>
          <el-col :span="12"><el-form-item label="结束周"><el-input-number v-model="scheduleDlg.form.endWeek" :min="1" /></el-form-item></el-col>
        </el-row>
      </el-form>
      <template #footer><el-button @click="scheduleDlg.visible = false">取消</el-button><el-button type="primary" @click="saveSchedule">保存</el-button></template>
    </el-dialog>

    <el-dialog v-model="teachingDlg.visible" title="教学纪实" width="500px">
      <el-form label-width="90px">
        <el-form-item label="班级ID"><el-input-number v-model="teachingDlg.form.classId" :min="1" /></el-form-item>
        <el-form-item label="课程ID"><el-input-number v-model="teachingDlg.form.courseId" :min="1" /></el-form-item>
        <el-form-item label="授课日期"><el-date-picker v-model="teachingDlg.form.teachDate" type="date" value-format="YYYY-MM-DD" style="width: 100%" /></el-form-item>
        <el-form-item label="教学内容"><el-input v-model="teachingDlg.form.content" type="textarea" :rows="3" /></el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="teachingDlg.visible = false">取消</el-button>
        <el-button type="primary" @click="saveTeaching">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import { eduApi, examApi } from '@/api/k12'

const tab = ref('course')
const courses = ref<any[]>([])
const schedules = ref<any[]>([])
const exams = ref<any[]>([])
const scores = ref<any[]>([])
const examFilter = ref<number>()
const teachingList = ref<any[]>([])
const examTypes = [
  { label: '单元测', value: 'unit' }, { label: '周测', value: 'weekly' }, { label: '月考', value: 'monthly' },
  { label: '期中', value: 'midterm' }, { label: '期末', value: 'final' }, { label: '模考', value: 'model' }, { label: '联考', value: 'union' }
]
const courseTypeName = (v: string) => ({ required: '必修', elective: '选修', club: '社团', exam_core: '中考核心', gaokao: '高考学科' }[v] || v)
const examTypeName = (v: string) => examTypes.find((t) => t.value === v)?.label || v

const courseDlg = reactive({ visible: false, form: {} as any })
const examDlg = reactive({ visible: false, form: {} as any })
const teachingDlg = reactive({ visible: false, form: {} as any })
const scheduleDlg = reactive({ visible: false, form: {} as any })

async function loadCourses() { courses.value = await eduApi.listCourses({}) }
async function loadSchedules() { schedules.value = await eduApi.listSchedules({}) }
async function loadExams() {
  const res = await examApi.pageExam({ current: 1, size: 50 })
  exams.value = res.records
}
async function loadScores() {
  if (!examFilter.value) { scores.value = []; return }
  const res = await examApi.pageScore({ current: 1, size: 50, examId: examFilter.value })
  scores.value = res.records
}
async function loadTeaching() {
  const res = await eduApi.pageTeaching({ current: 1, size: 20 })
  teachingList.value = res.records
}

function openCourse() { courseDlg.form = { courseName: '', subjectCode: '', courseType: 'required', gradeId: 1, periodsWeek: 2 }; courseDlg.visible = true }
async function saveCourse() { await eduApi.saveCourse(courseDlg.form); ElMessage.success('已保存'); courseDlg.visible = false; loadCourses() }
function openSchedule() {
  scheduleDlg.form = { weekday: 1, sectionNo: 1, courseId: 1, teacherId: 1, classId: 1, room: '', startWeek: 1, endWeek: 20, scheduleType: 'normal' }
  scheduleDlg.visible = true
}
async function saveSchedule() {
  await eduApi.saveSchedule(scheduleDlg.form)
  ElMessage.success('课表条目已保存')
  scheduleDlg.visible = false
  loadSchedules()
}
function openExam() { examDlg.form = { examName: '', examType: 'midterm', gradeId: 1, examDate: '' }; examDlg.visible = true }
async function saveExam() { await examApi.saveExam(examDlg.form); ElMessage.success('考试已创建'); examDlg.visible = false; loadExams() }
function openTeaching() { teachingDlg.form = { classId: 1, courseId: 1, teachDate: '' }; teachingDlg.visible = true }
async function saveTeaching() { await eduApi.saveTeaching(teachingDlg.form); ElMessage.success('已保存'); teachingDlg.visible = false; loadTeaching() }

onMounted(() => { loadCourses(); loadSchedules(); loadExams(); loadTeaching() })
</script>

<style scoped>
.toolbar { display: flex; gap: 10px; margin-bottom: 14px; }
</style>