import Foundation

// MARK: - App Language

enum AppLanguage: String, CaseIterable {
    case english = "en"
    case korean = "ko"
    case spanish = "es"

    var displayName: String {
        switch self {
        case .english: return "English"
        case .korean: return "한국어"
        case .spanish: return "Español"
        }
    }
}

extension Notification.Name {
    static let appLanguageChanged = Notification.Name("NonZeroAppLanguageChanged")
}

// MARK: - Global Helper

/// Translates a key using the active in-app language.
func loc(_ key: String) -> String {
    switch LanguageManager.shared.currentLanguage {
    case .english: return key
    case .korean:  return koreanTranslations[key] ?? key
    case .spanish: return spanishTranslations[key] ?? key
    }
}

// MARK: - Language Manager

final class LanguageManager {
    static let shared = LanguageManager()

    private(set) var currentLanguage: AppLanguage

    private init() {
        let saved = UserDefaults.standard.string(forKey: "appLanguage") ?? AppLanguage.english.rawValue
        currentLanguage = AppLanguage(rawValue: saved) ?? .english
    }

    func setLanguage(_ language: AppLanguage) {
        currentLanguage = language
        UserDefaults.standard.set(language.rawValue, forKey: "appLanguage")
        NotificationCenter.default.post(name: .appLanguageChanged, object: nil)
    }
}

// MARK: - Korean Translations

private let koreanTranslations: [String: String] = [
    // Tab bar
    "Today": "오늘",
    "Tasks": "할 일",
    "Stats": "통계",
    "Settings": "설정",

    // Today view
    "No Tasks Yet": "할 일 없음",
    "Add tasks in the Tasks tab to start tracking": "관리를 위해 할 일을 탭에서 추가",
    "Today is Non-Zero": "오늘은 논제로!",
    "Make Today Non-Zero": "오늘을 논제로로 만드세요",
    "Did It!": "완료!",
    "Mark Done": "완료 표시",
    "Stop": "정지",

    // Tasks list
    "No Tasks": "할 일 없음",
    "Add your first task to get started": "첫 번째 할 일을 추가하세요",
    "Try with Sample Data": "샘플 데이터로 시작",
    "Reorder": "순서 변경",
    "Delete Task": "할 일 삭제",
    "Cancel": "취소",
    "Delete": "삭제",
    "Min:": "최소:",
    "Goal:": "목표:",

    // Task editor
    "New Task": "새 할 일",
    "Edit Task": "할 일 수정",
    "Task Details": "자세한 정보",
    "Task Name": "할 일 이름",
    "Type": "종류",
    "Unit": "단위",
    "Enter custom unit": "사용자 정의 단위",
    "None": "없음",
    "Pages": "페이지",
    "Cups": "컵",
    "Steps": "걸음",
    "Custom": "사용자 정의",
    "Targets": "목표 설정",
    "Minimum": "최소",
    "Set Goal": "목표 설정",
    "Goal": "목표",
    "App Integration": "앱 연동",
    "Fitness (HealthKit)": "피트니스 (HealthKit)",
    "Workout Type": "운동 유형",
    "Exercise Minutes (Ring)": "운동 시간 (링)",
    "All Workouts": "모든 운동",
    "Automatically sync workout data from other fitness apps. You'll be asked for permission on first use.": "다른 피트니스 앱의 운동 데이터를 자동으로 동기화합니다. 처음 사용 시 권한을 요청합니다.",
    "Example": "예시",
    "Save": "저장",
    // footer texts (computed)
    "A day counts as Non-Zero if you mark it as done.": "완료로 표시하면 그 날은 논제로로 기록됩니다.",
    "A day counts as Non-Zero if you reach the minimum count.": "최소 횟수를 달성하면 그 날은 논제로로 기록됩니다.",
    "A day counts as Non-Zero if you reach the minimum time (in minutes). You can manually add time or use the built-in timer.": "최소 시간(분)을 달성하면 그 날은 논제로로 기록됩니다. 직접 시간을 추가하거나 타이머를 사용할 수 있습니다.",
    // example texts (computed)
    "Example: 'Meditation' with minimum 1 means any meditation session counts as a Non-Zero day.": "예: '명상'의 최소값을 1로 설정하면 어떤 명상 세션이든 논제로로 인정됩니다.",
    "Example: 'Pushups' with minimum 5 means doing at least 5 pushups makes it a Non-Zero day. Goal of 20 gives you a target to aim for.": "예: '푸시업'의 최소값을 5로 설정하면 5개 이상 하면 논제로입니다. 목표 20은 도달해야 할 기준입니다.",
    "Example: 'Reading' with minimum 10 minutes and goal 30 minutes. You can add time manually (+5m, +15m, +30m buttons) or use the timer for continuous tracking.": "예: '독서'를 최소 10분, 목표 30분으로 설정하세요. 버튼으로 시간을 추가하거나 타이머를 사용할 수 있습니다.",

    // Stats view
    "No Stats Yet": "통계 없음",
    "Add tasks and log entries to see your progress": "할 일을 추가하고 기록하면 통계가 나타납니다",
    "Day Score": "오늘의 점수",
    "Comeback": "복귀",
    "Resilience": "회복력",
    "Streak": "연속",
    "Last 7 Days": "최근 7일",

    // Stats cards
    "Current Streak": "현재 연속",
    "Longest Streak": "최장 연속",
    "Best Streak": "최장 연속",
    "Comebacks": "복귀 횟수",
    "7-Day Rate": "7일 달성률",
    "30-Day Rate": "30일 달성률",
    "90-Day Rate": "90일 달성률",
    "days": "일",
    "times": "회",
    "complete": "달성",
    "total": "합계",

    // Task detail
    "Statistics": "통계",
    "Non-Zero Days": "논제로 일수",
    "Resilience Index": "회복 지수",
    "Days to Return": "복귀 소요일",
    "Completion Rates": "달성률",
    "7 Days": "7일",
    "30 Days": "30일",
    "90 Days": "90일",
    "Recent Entries": "최근 기록",

    // Settings
    "Welcome Screen": "시작 화면",
    "The NonZero Principle": "논제로 원칙",
    "Show Badge": "배지 표시",
    "Sounds": "소리",
    "Day Score Criteria": "일간 점수 기준",
    "Health Integration": "건강 연동",
    "Send Feedback": "피드백 보내기",
    "Manage Data": "데이터 관리",
    "Language": "언어",

    // Manage Data
    "Export Tasks": "할 일 내보내기",
    "Import Tasks": "할 일 가져오기",
    "Export Backup": "백업 내보내기",
    "Restore Backup": "백업 복원",
    "Load Sample Data": "샘플 데이터 불러오기",
    "Reset All Records": "모든 기록 초기화",
    "Reset All Records?": "모든 기록을 초기화하시겠습니까?",
    "Reset": "초기화",
    "This will permanently delete all your logged entries (streaks, progress, history) but keep your task definitions. This action cannot be undone.": "모든 기록(연속 달성, 진행 상황, 이력)이 삭제됩니다. 할 일 정의는 유지됩니다. 이 작업은 되돌릴 수 없습니다.",
    "Restore Backup?": "백업을 복원하시겠습니까?",
    "Replace All Data": "모든 데이터 교체",
    "This will delete all existing tasks and entries, then restore from the backup file. This action cannot be undone.": "기존의 모든 할 일과 기록이 삭제되고 백업 파일에서 복원됩니다. 이 작업은 되돌릴 수 없습니다.",
    "Import Result": "가져오기 결과",
    "OK": "확인",
    "Sample data loaded successfully": "샘플 데이터가 불러와졌습니다",
    "Cannot access file": "파일에 접근할 수 없습니다",

    // NonZero Principle view
    "The rule is simple.": "규칙은 단순합니다.",
    "Do not let a day become zero.": "하루를 제로로 만들지 마세요.",
    "You don't have to be perfect.\nYou don't have to complete everything.": "완벽할 필요가 없습니다.\n모든 것을 완료할 필요도 없습니다.",
    "Just non-zero. \n1 page, 1 push-up, 1 min conversation...": "그저 논제로. \n1페이지, 푸시업 1개, 1분 대화...",
    "You may have a zero-day. \nNo worries. Come back. Start small.": "제로 데이가 있어도 괜찮습니다. \n걱정 말고 돌아오세요. 작게 시작하세요.",

    // Resilience Index view
    "Resilience is not about never struggling.\nIt is about responding to struggle by returning.": "회복력은 어려움을 겪지 않는 것이 아닙니다.\n어려움에 맞서 돌아오는 것입니다.",
    "In psychology, resilience is often described as the ability to bounce back from setbacks and adapt after difficulty. The Resilience Index reflects this idea in behavioral form. It measures how consistently you resume your efforts after missing days.": "심리학에서 회복력은 좌절로부터 회복하고 어려움 이후 적응하는 능력으로 설명됩니다. 회복 지수는 이 개념을 행동 형태로 반영합니다. 빠진 날 이후 얼마나 일관되게 다시 시작하는지를 측정합니다.",
    "When you miss a day and return, that is resilience. When you miss several days and still return, that is resilience too — because resilience is not perfection, but persistence.": "하루를 놓치고 돌아오는 것이 회복력입니다. 며칠을 놓쳐도 돌아오는 것도 회복력입니다. 회복력은 완벽함이 아닌 지속성이기 때문입니다.",
    "The index considers two patterns:": "이 지수는 두 가지 패턴을 고려합니다:",
    "How reliably you return": "얼마나 꾸준히 돌아오는가",
    "How quickly you resume": "얼마나 빨리 재개하는가",
    "Recent comebacks carry more weight than distant ones, because resilience is something practiced in the present. Long gaps do not erase your resilience. They simply make your return more meaningful.": "최근 복귀일수록 더 높은 가중치가 부여됩니다. 회복력은 현재에서 실천하는 것이기 때문입니다. 오랜 공백이 회복력을 지우지는 않습니다. 오히려 복귀를 더 의미 있게 만들 뿐입니다.",
    "This index is not a clinical assessment or a personality score. It is a reflection of your pattern of persistence over time. In that sense, it is closely related to what researchers call \"grit\" — the capacity to continue showing up for what matters.": "이 지수는 임상 평가나 성격 점수가 아닙니다. 시간이 지남에 따른 지속성의 패턴을 반영합니다. 이는 연구자들이 '그릿(grit)'이라고 부르는 것과 밀접하게 연관됩니다.",
    "As long as you refuse to drop and keep returning, your resilience remains active.": "포기하지 않고 계속 돌아오는 한, 당신의 회복력은 살아있습니다.",

    // Health Integration
    "NonZero uses Apple HealthKit to help you track fitness-related tasks automatically.": "NonZero는 Apple HealthKit을 사용하여 피트니스 관련 할 일을 자동으로 추적합니다.",
    "What We Access": "액세스하는 데이터",
    "Workout Data": "운동 데이터",
    "Duration and type of workouts recorded in the Health app or other fitness apps.": "건강 앱 또는 다른 피트니스 앱에 기록된 운동의 시간과 유형.",
    "Exercise Minutes": "운동 시간",
    "Daily exercise minutes from your Activity rings to automatically log time-based tasks.": "활동 링의 일일 운동 시간을 기반으로 시간 기반 할 일을 자동으로 기록합니다.",
    "How It Works": "작동 방식",
    "When you create a time-based task and enable HealthKit integration, NonZero reads your workout data to automatically update your daily progress. This helps you track fitness habits without manual entry.": "시간 기반 할 일을 만들고 HealthKit 연동을 활성화하면, NonZero가 운동 데이터를 읽어 일일 진행 상황을 자동으로 업데이트합니다.",
    "You can enable or disable HealthKit for each task individually in the task editor.": "할 일 편집기에서 각 할 일별로 HealthKit을 개별 활성화/비활성화할 수 있습니다.",
    "Your Privacy": "개인 정보",
    "NonZero only reads health data — it never writes to or modifies your Health records. All data stays on your device and is never sent to any server.": "NonZero는 건강 데이터를 읽기만 하며 절대 작성하거나 수정하지 않습니다. 모든 데이터는 기기에 보관되며 서버로 전송되지 않습니다.",
    "Manage Health Permissions": "건강 권한 관리",

    // Feedback
    "Your Feedback": "피드백 내용",
    "Tell us what you like, what could be better, or report a bug.": "좋은 점, 개선할 점, 또는 버그를 알려주세요.",
    "Send via Email": "이메일로 보내기",
    "Email": "이메일",
    "App Version": "앱 버전",
    "Device": "기기",
    "Info": "정보",
    "Cannot Send Email": "이메일을 보낼 수 없습니다",
    "Copy Email Address": "이메일 주소 복사",
    "Your device is not configured to send email. You can copy the email address and send feedback manually.": "이 기기에서 이메일을 보낼 수 없습니다. 이메일 주소를 복사하여 직접 피드백을 보내세요.",
    "Thank You!": "감사합니다!",
    "Your feedback email has been prepared. Please send it from your email app.": "피드백 이메일이 준비되었습니다. 이메일 앱에서 보내주세요.",

    // Onboarding
    "Make every day count": "매일을 의미 있게",
    "Track Your Way": "나만의 방식으로 추적",
    "Boolean, count, or timed tasks — whatever fits your habit": "체크, 횟수, 시간 — 원하는 방식으로",
    "Build Momentum": "동력을 쌓으세요",
    "Stay consistent day by day and build momentum": "매일 꾸준히 동력을 키워가세요",
    "See Your Progress": "진행 상황 확인",
    "Stats, heatmaps, and comeback tracking at a glance": "통계, 히트맵, 복귀 추적을 한눈에",
    "Stay Connected": "연결 유지",
    "Sync with HealthKit and the Fitness app automatically": "HealthKit 및 피트니스 앱과 자동 동기화",
    "Get Started": "시작하기",

    // Common
    "NonZero": "NonZero",
]

// MARK: - Spanish Translations

private let spanishTranslations: [String: String] = [
    // Tab bar
    "Today": "Hoy",
    "Tasks": "Tareas",
    "Stats": "Estadísticas",
    "Settings": "Ajustes",

    // Today view
    "No Tasks Yet": "Sin tareas",
    "Add tasks in the Tasks tab to start tracking": "Agrega tareas en la pestaña Tareas para comenzar",
    "Today is Non-Zero": "¡Hoy es Non-Zero!",
    "Make Today Non-Zero": "Haz que hoy sea Non-Zero",
    "Did It!": "¡Hecho!",
    "Mark Done": "Marcar listo",
    "Stop": "Detener",

    // Tasks list
    "No Tasks": "Sin tareas",
    "Add your first task to get started": "Agrega tu primera tarea para empezar",
    "Try with Sample Data": "Probar con datos de ejemplo",
    "Reorder": "Reordenar",
    "Delete Task": "Eliminar tarea",
    "Cancel": "Cancelar",
    "Delete": "Eliminar",
    "Min:": "Mín:",
    "Goal:": "Meta:",

    // Task editor
    "New Task": "Nueva tarea",
    "Edit Task": "Editar tarea",
    "Task Details": "Detalles",
    "Task Name": "Nombre de la tarea",
    "Type": "Tipo",
    "Unit": "Unidad",
    "Enter custom unit": "Ingresa una unidad personalizada",
    "None": "Ninguna",
    "Pages": "Páginas",
    "Cups": "Tazas",
    "Steps": "Pasos",
    "Custom": "Personalizado",
    "Targets": "Objetivos",
    "Minimum": "Mínimo",
    "Set Goal": "Establecer meta",
    "Goal": "Meta",
    "App Integration": "Integración de apps",
    "Fitness (HealthKit)": "Actividad física (HealthKit)",
    "Workout Type": "Tipo de ejercicio",
    "Exercise Minutes (Ring)": "Minutos de ejercicio (Anillo)",
    "All Workouts": "Todos los entrenamientos",
    "Automatically sync workout data from other fitness apps. You'll be asked for permission on first use.": "Sincroniza automáticamente tus datos de ejercicio. Se pedirá permiso la primera vez.",
    "Example": "Ejemplo",
    "Save": "Guardar",
    // footer texts (computed)
    "A day counts as Non-Zero if you mark it as done.": "Un día cuenta como Non-Zero si lo marcas como completado.",
    "A day counts as Non-Zero if you reach the minimum count.": "Un día cuenta como Non-Zero si alcanzas el mínimo de repeticiones.",
    "A day counts as Non-Zero if you reach the minimum time (in minutes). You can manually add time or use the built-in timer.": "Un día cuenta como Non-Zero si alcanzas el tiempo mínimo (en minutos). Puedes agregar tiempo manualmente o usar el temporizador.",
    // example texts (computed)
    "Example: 'Meditation' with minimum 1 means any meditation session counts as a Non-Zero day.": "Ejemplo: 'Meditación' con mínimo 1 significa que cualquier sesión de meditación cuenta como Non-Zero.",
    "Example: 'Pushups' with minimum 5 means doing at least 5 pushups makes it a Non-Zero day. Goal of 20 gives you a target to aim for.": "Ejemplo: 'Flexiones' con mínimo 5 significa que hacer al menos 5 flexiones hace el día Non-Zero. Una meta de 20 te da un objetivo.",
    "Example: 'Reading' with minimum 10 minutes and goal 30 minutes. You can add time manually (+5m, +15m, +30m buttons) or use the timer for continuous tracking.": "Ejemplo: 'Lectura' con mínimo 10 minutos y meta 30 minutos. Agrega tiempo manualmente o usa el temporizador.",

    // Stats view
    "No Stats Yet": "Sin estadísticas",
    "Add tasks and log entries to see your progress": "Agrega tareas y registros para ver tu progreso",
    "Day Score": "Puntuación del día",
    "Comeback": "Regreso",
    "Resilience": "Resiliencia",
    "Streak": "Racha",
    "Last 7 Days": "Últimos 7 días",

    // Stats cards
    "Current Streak": "Racha actual",
    "Longest Streak": "Racha más larga",
    "Best Streak": "Mejor racha",
    "Comebacks": "Regresos",
    "7-Day Rate": "Tasa de 7 días",
    "30-Day Rate": "Tasa de 30 días",
    "90-Day Rate": "Tasa de 90 días",
    "days": "días",
    "times": "veces",
    "complete": "completo",
    "total": "total",

    // Task detail
    "Statistics": "Estadísticas",
    "Non-Zero Days": "Días Non-Zero",
    "Resilience Index": "Índice de resiliencia",
    "Days to Return": "Días para volver",
    "Completion Rates": "Tasas de cumplimiento",
    "7 Days": "7 días",
    "30 Days": "30 días",
    "90 Days": "90 días",
    "Recent Entries": "Registros recientes",

    // Settings
    "Welcome Screen": "Pantalla de bienvenida",
    "The NonZero Principle": "El principio NonZero",
    "Show Badge": "Mostrar insignia",
    "Sounds": "Sonidos",
    "Day Score Criteria": "Criterio de puntuación diaria",
    "Health Integration": "Integración de salud",
    "Send Feedback": "Enviar comentarios",
    "Manage Data": "Administrar datos",
    "Language": "Idioma",

    // Manage Data
    "Export Tasks": "Exportar tareas",
    "Import Tasks": "Importar tareas",
    "Export Backup": "Exportar copia de seguridad",
    "Restore Backup": "Restaurar copia de seguridad",
    "Load Sample Data": "Cargar datos de ejemplo",
    "Reset All Records": "Restablecer todos los registros",
    "Reset All Records?": "¿Restablecer todos los registros?",
    "Reset": "Restablecer",
    "This will permanently delete all your logged entries (streaks, progress, history) but keep your task definitions. This action cannot be undone.": "Esto eliminará permanentemente todos tus registros (rachas, progreso, historial) pero mantendrá tus tareas. Esta acción no se puede deshacer.",
    "Restore Backup?": "¿Restaurar copia de seguridad?",
    "Replace All Data": "Reemplazar todos los datos",
    "This will delete all existing tasks and entries, then restore from the backup file. This action cannot be undone.": "Esto eliminará todas las tareas y registros existentes, y luego restaurará desde el archivo de copia de seguridad. Esta acción no se puede deshacer.",
    "Import Result": "Resultado de importación",
    "OK": "Aceptar",
    "Sample data loaded successfully": "Datos de ejemplo cargados con éxito",
    "Cannot access file": "No se puede acceder al archivo",

    // NonZero Principle view
    "The rule is simple.": "La regla es simple.",
    "Do not let a day become zero.": "No dejes que un día sea cero.",
    "You don't have to be perfect.\nYou don't have to complete everything.": "No tienes que ser perfecto.\nNo tienes que completarlo todo.",
    "Just non-zero. \n1 page, 1 push-up, 1 min conversation...": "Solo non-zero. \n1 página, 1 flexión, 1 min de conversación...",
    "You may have a zero-day. \nNo worries. Come back. Start small.": "Puedes tener un día cero. \nNo te preocupes. Regresa. Empieza con poco.",

    // Resilience Index view
    "Resilience is not about never struggling.\nIt is about responding to struggle by returning.": "La resiliencia no es nunca tener dificultades.\nEs responder a las dificultades volviendo.",
    "In psychology, resilience is often described as the ability to bounce back from setbacks and adapt after difficulty. The Resilience Index reflects this idea in behavioral form. It measures how consistently you resume your efforts after missing days.": "En psicología, la resiliencia se describe como la capacidad de recuperarse de los contratiempos. El Índice de Resiliencia refleja esta idea midiendo qué tan consistentemente reanuidas tus esfuerzos después de días perdidos.",
    "When you miss a day and return, that is resilience. When you miss several days and still return, that is resilience too — because resilience is not perfection, but persistence.": "Cuando pierdes un día y vuelves, eso es resiliencia. Cuando pierdes varios días y aun así vuelves, también es resiliencia — porque la resiliencia no es perfección, sino persistencia.",
    "The index considers two patterns:": "El índice considera dos patrones:",
    "How reliably you return": "Qué tan consistentemente vuelves",
    "How quickly you resume": "Qué tan rápido reanuidas",
    "Recent comebacks carry more weight than distant ones, because resilience is something practiced in the present. Long gaps do not erase your resilience. They simply make your return more meaningful.": "Los regresos recientes tienen más peso que los antiguos, porque la resiliencia se practica en el presente. Las largas pausas no borran tu resiliencia. Simplemente hacen que tu regreso sea más significativo.",
    "This index is not a clinical assessment or a personality score. It is a reflection of your pattern of persistence over time. In that sense, it is closely related to what researchers call \"grit\" — the capacity to continue showing up for what matters.": "Este índice no es una evaluación clínica ni un puntaje de personalidad. Es un reflejo de tu patrón de persistencia en el tiempo, relacionado con lo que los investigadores llaman \"agallas\".",
    "As long as you refuse to drop and keep returning, your resilience remains active.": "Mientras te niegues a rendirte y sigas volviendo, tu resiliencia sigue activa.",

    // Health Integration
    "NonZero uses Apple HealthKit to help you track fitness-related tasks automatically.": "NonZero usa Apple HealthKit para ayudarte a rastrear automáticamente las tareas relacionadas con el ejercicio.",
    "What We Access": "Qué accedemos",
    "Workout Data": "Datos de entrenamiento",
    "Duration and type of workouts recorded in the Health app or other fitness apps.": "Duración y tipo de entrenamientos registrados en la app Salud u otras apps de fitness.",
    "Exercise Minutes": "Minutos de ejercicio",
    "Daily exercise minutes from your Activity rings to automatically log time-based tasks.": "Minutos de ejercicio diarios de tus anillos de Actividad para registrar automáticamente tareas basadas en tiempo.",
    "How It Works": "Cómo funciona",
    "When you create a time-based task and enable HealthKit integration, NonZero reads your workout data to automatically update your daily progress. This helps you track fitness habits without manual entry.": "Cuando creas una tarea basada en tiempo y activas la integración con HealthKit, NonZero lee tus datos de entrenamiento para actualizar automáticamente tu progreso diario.",
    "You can enable or disable HealthKit for each task individually in the task editor.": "Puedes activar o desactivar HealthKit para cada tarea individualmente en el editor de tareas.",
    "Your Privacy": "Tu privacidad",
    "NonZero only reads health data — it never writes to or modifies your Health records. All data stays on your device and is never sent to any server.": "NonZero solo lee datos de salud, nunca escribe ni modifica tus registros de Salud. Todos los datos permanecen en tu dispositivo.",
    "Manage Health Permissions": "Gestionar permisos de salud",

    // Feedback
    "Your Feedback": "Tu opinión",
    "Tell us what you like, what could be better, or report a bug.": "Cuéntanos qué te gusta, qué podría mejorar o reporta un error.",
    "Send via Email": "Enviar por correo",
    "Email": "Correo",
    "App Version": "Versión de la app",
    "Device": "Dispositivo",
    "Info": "Información",
    "Cannot Send Email": "No se puede enviar correo",
    "Copy Email Address": "Copiar dirección de correo",
    "Your device is not configured to send email. You can copy the email address and send feedback manually.": "Tu dispositivo no está configurado para enviar correo. Puedes copiar la dirección y enviar los comentarios manualmente.",
    "Thank You!": "¡Gracias!",
    "Your feedback email has been prepared. Please send it from your email app.": "Tu correo de comentarios está listo. Por favor envíalo desde tu app de correo.",

    // Onboarding
    "Make every day count": "Haz que cada día cuente",
    "Track Your Way": "Registra a tu manera",
    "Boolean, count, or timed tasks — whatever fits your habit": "Tareas booleanas, de conteo o de tiempo — lo que mejor se adapte",
    "Build Momentum": "Crea impulso",
    "Stay consistent day by day and build momentum": "Sé constante día a día y crea impulso",
    "See Your Progress": "Ve tu progreso",
    "Stats, heatmaps, and comeback tracking at a glance": "Estadísticas, mapas de calor y seguimiento de regresos de un vistazo",
    "Stay Connected": "Mantente conectado",
    "Sync with HealthKit and the Fitness app automatically": "Sincroniza automáticamente con HealthKit y la app de Actividad",
    "Get Started": "Comenzar",

    // Common
    "NonZero": "NonZero",
]
