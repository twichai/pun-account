import 'package:shadcn_flutter/shadcn_flutter.dart';

/// ธุรกิจ (Business Profile & Settings screen) for solopreneurs.
class BusinessScreen extends StatelessWidget {
  const BusinessScreen({
    super.key,
    this.onToggleTheme,
  });

  final VoidCallback? onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ข้อมูลธุรกิจ').h3(),
                  const SizedBox(height: 4),
                  const Text('One Person Company (OPC)').muted(),
                ],
              ),
              OutlineButton(
                density: ButtonDensity.icon,
                onPressed: onToggleTheme,
                child: Icon(isDark ? LucideIcons.sun : LucideIcons.moon, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Business Profile Header Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: const Text('🐣', style: TextStyle(fontSize: 28)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('ปั้น สตูดิโอ').h4(),
                            const SizedBox(width: 8),
                            const PrimaryBadge(
                              child: Text('Solopreneur'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text('ผู้ประกอบการเดี่ยว • ให้คำปรึกษา & พัฒนาซอฟต์แวร์').muted().small(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Tax & Compliance Status
          const Text('ภาษีและข้อกำหนด').h4(),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('เกณฑ์ภาษีมูลค่าเพิ่ม (VAT)').semiBold(),
                          const SizedBox(height: 2),
                          const Text('รายรับสะสมปีนี้ ฿ 645,000 / ฿ 1,800,000').muted().small(),
                        ],
                      ),
                      const SecondaryBadge(
                        child: Text('ไม่ต้องจด VAT'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Shadcn Progress bar
                  const Progress(
                    progress: 645000 / 1800000,
                  ),
                  const SizedBox(height: 14),
                  const Divider(),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('ประมาณการภาษีเงินได้สิ้นปี').small(),
                      const Text('฿ 18,500.00').semiBold(),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Settings List
          const Text('การตั้งค่าระบบ').h4(),
          const SizedBox(height: 12),
          Card(
            child: ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildSettingTile(
                  icon: LucideIcons.tag,
                  title: 'จัดการหมวดหมู่รายรับ-รายจ่าย',
                  subtitle: 'กำหนดหมวดหมู่และอัตราภาษีหัก ณ ที่จ่าย',
                  trailing: const Icon(LucideIcons.chevronRight, size: 16),
                ),
                const Divider(),
                _buildSettingTile(
                  icon: LucideIcons.database,
                  title: 'การเชื่อมต่อระบบหลังบ้าน (Go Backend)',
                  subtitle: 'PostgreSQL • Goose Migrations v2',
                  trailing: const OutlineBadge(child: Text('Connected')),
                ),
                const Divider(),
                _buildSettingTile(
                  icon: LucideIcons.shieldCheck,
                  title: 'สำรองข้อมูลและบันทึกตรวจสอบ (Audit Ledger)',
                  subtitle: 'ความถูกต้องของยอดเงินตามมาตรฐานบัญชี',
                  trailing: const Icon(LucideIcons.chevronRight, size: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title).semiBold(),
                const SizedBox(height: 2),
                Text(subtitle).muted().small(),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
