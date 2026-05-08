import 'package:flutter/material.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/account_confirm_screen.dart';
import '../screens/auth/account_info_screen.dart';
import '../screens/auth/member_type_screen.dart';
import '../screens/main_screen.dart';
import '../screens/ai_chat_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/post_detail_screen.dart';
import '../screens/my_page_screen.dart';
import '../screens/channel_manage_screen.dart';
import '../screens/portfolio_screen.dart';
import '../screens/channel_analysis_screen.dart';
import '../screens/participated_content_screen.dart';
import '../screens/profile_manage_screen.dart';
import '../screens/editor_main_screen.dart';
import '../screens/editor_post_register_screen.dart';
import '../screens/editor_my_page_screen.dart';
import '../screens/editor_posted_screen.dart';
import '../screens/editor_resume_list_screen.dart';
import '../screens/editor_resume_view_screen.dart';
import '../screens/editor_chat_screen.dart';
import '../screens/creator_channel_screen.dart';
import '../screens/editor_made_content_screen.dart';
import '../screens/dm_chat_screen.dart';

class AppRoutes {
  static const login = '/login';
  static const signup = '/signup';
  static const memberType = '/member-type';
  static const accountConfirm = '/account-confirm';
  static const accountInfo = '/account-info';
  static const main = '/main';
  static const aiChat = '/ai';
  static const chat = '/chat';
  static const postDetail = '/post-detail';
  static const myPage = '/my-page';
  static const channelManage = '/channel-manage';
  static const portfolio = '/portfolio';
  static const channelAnalysis = '/channel-analysis';
  static const participatedContent = '/participated-content';
  static const profileManage = '/profile-manage';
  static const editorMain = '/editor-main';
  static const editorPostRegister = '/editor-post-register';
  static const editorMyPage = '/editor-my-page';
  static const editorPosted = '/editor-posted';
  static const editorResumeList = '/editor-resume-list';
  static const editorResumeView = '/editor-resume-view';
  static const editorChat = '/editor-chat';
  static const creatorChannel = '/creator-channel';
  static const editorMadeContent = '/editor-made-content';
  static const dmChat = '/dm-chat';
  static const dmChatCreator = '/dm-chat-creator';
}

Map<String, WidgetBuilder> get appRoutes => {
  AppRoutes.login: (_) => const LoginScreen(),
  AppRoutes.signup: (_) => const SignupScreen(),
  AppRoutes.memberType: (_) => const MemberTypeScreen(),
  AppRoutes.accountConfirm: (_) => const AccountConfirmScreen(),
  AppRoutes.accountInfo: (_) => const AccountInfoScreen(),
  AppRoutes.main: (_) => const MainScreen(),
  AppRoutes.aiChat: (_) => const AiChatScreen(),
  AppRoutes.chat: (_) => const ChatScreen(),
  AppRoutes.postDetail: (_) => const PostDetailScreen(),
  AppRoutes.myPage: (_) => const MyPageScreen(),
  AppRoutes.channelManage: (_) => const ChannelManageScreen(),
  AppRoutes.portfolio: (_) => const PortfolioScreen(),
  AppRoutes.channelAnalysis: (_) => const ChannelAnalysisScreen(),
  AppRoutes.participatedContent: (_) => const ParticipatedContentScreen(),
  AppRoutes.profileManage: (_) => const ProfileManageScreen(),
  AppRoutes.editorMain: (_) => const EditorMainScreen(),
  AppRoutes.editorPostRegister: (_) => const EditorPostRegisterScreen(),
  AppRoutes.editorMyPage: (_) => const EditorMyPageScreen(),
  AppRoutes.editorPosted: (_) => const EditorPostedScreen(),
  AppRoutes.editorResumeList: (_) => const EditorResumeListScreen(),
  AppRoutes.editorResumeView: (_) => const EditorResumeViewScreen(),
  AppRoutes.editorChat: (_) => const EditorChatScreen(),
  AppRoutes.creatorChannel: (_) => const CreatorChannelScreen(),
  AppRoutes.editorMadeContent: (_) => const EditorMadeContentScreen(),
  AppRoutes.dmChat: (_) => const DmChatScreen(otherUserId: 'user_206e7fcd', otherUserName: '이동주 (크리에이터)'),
  AppRoutes.dmChatCreator: (_) => const DmChatScreen(otherUserId: 'user_206e7fcd', otherUserName: '이동주 (크리에이터)'),
};
