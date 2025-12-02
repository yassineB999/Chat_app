import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nexuschatfe/core/services/pusher_config.dart';
import 'package:nexuschatfe/features/auth/data/data_sources/local/auth_local_service.dart';
import 'package:nexuschatfe/features/chat/data/models/chat_message_model.dart';
import 'package:nexuschatfe/features/chat/domain/entities/chat_message.dart';
import 'package:nexuschatfe/features/chat/domain/use_case/get_chat_rooms.dart';
import 'package:nexuschatfe/features/chat/domain/use_case/get_messages.dart';
import 'package:nexuschatfe/features/chat/domain/use_case/provide_chat_room.dart';
import 'package:nexuschatfe/features/chat/domain/use_case/search_users.dart';
import 'package:nexuschatfe/features/chat/domain/use_case/send_message.dart';
import 'package:nexuschatfe/features/chat/presentation/bloc/chat_event.dart';
import 'package:nexuschatfe/features/chat/presentation/bloc/chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetChatRooms getChatRooms;
  final GetMessages getMessages;
  final SendMessage sendMessage;
  final SearchUsers searchUsers;
  final ProvideChatRoom provideChatRoom;
  final PusherConfig pusherConfig;
  final AuthLocalService authLocalService;

  bool _pusherInitialized = false;

  ChatBloc({
    required this.getChatRooms,
    required this.getMessages,
    required this.sendMessage,
    required this.searchUsers,
    required this.provideChatRoom,
    required this.pusherConfig,
    required this.authLocalService,
  }) : super(ChatInitial()) {
    on<LoadChatRooms>(_onLoadChatRooms);
    on<LoadMessages>(_onLoadMessages);
    on<SendMessageEvent>(_onSendMessage);
    on<SearchUsersEvent>(_onSearchUsers);
    on<CreateChatRoom>(_onCreateChatRoom);
    on<SubscribeToChatChannel>(_onSubscribeToChatChannel);
    on<UnsubscribeFromChatChannel>(_onUnsubscribeFromChatChannel);
    on<ReceiveMessage>(_onReceiveMessage);
    on<ResetChatState>(_onResetChatState);
  }

  Future<void> _onLoadChatRooms(
    LoadChatRooms event,
    Emitter<ChatState> emit,
  ) async {
    print('🔄 [ChatBloc] Loading chat rooms...');
    emit(ChatRoomsLoading());
    try {
      final result = await getChatRooms();
      result.fold(
        (failure) {
          print('❌ [ChatBloc] Error loading chat rooms: ${failure.message}');
          emit(ChatError(failure.message));
        },
        (rooms) {
          print('✅ [ChatBloc] Chat rooms loaded: ${rooms.length}');
          emit(ChatRoomsLoaded(rooms));
        },
      );
    } catch (e) {
      print('❌ [ChatBloc] Unexpected error loading chat rooms: $e');
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onLoadMessages(
    LoadMessages event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatMessagesLoading());
    final result = await getMessages(event.roomId);
    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (messages) =>
          emit(ChatMessagesLoaded(messages: messages, roomId: event.roomId)),
    );
  }

  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    print('📤 Sending message: ${event.content}');
    // Get socket ID for broadcast filtering
    final socketId = await pusherConfig.getSocketId();
    print('🔌 Socket ID: $socketId');

    // Optimistic update could be implemented here, but for now we'll wait for server
    final result = await sendMessage(
      roomId: event.roomId,
      content: event.content,
      type: event.type,
      socketId: socketId,
      file: event.file,
    );

    result.fold(
      (failure) {
        print('❌ Error sending message: ${failure.message}');
        emit(ChatError(failure.message));
      },
      (message) {
        print('✅ Message sent successfully: ${message.id}');
        // If we are currently viewing messages for this room, append the new message
        if (state is ChatMessagesLoaded) {
          final currentState = state as ChatMessagesLoaded;
          if (currentState.roomId == event.roomId) {
            final updatedMessages = List<ChatMessage>.from(
              currentState.messages,
            )..add(message);
            emit(
              ChatMessagesLoaded(
                messages: updatedMessages,
                roomId: event.roomId,
              ),
            );
          }
        }
      },
    );
  }

  Future<void> _onSearchUsers(
    SearchUsersEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatRoomsLoading());
    final result = await searchUsers(event.query);
    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (users) => emit(UserSearchResultsLoaded(users)),
    );
  }

  Future<void> _onCreateChatRoom(
    CreateChatRoom event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatRoomsLoading());
    final result = await provideChatRoom(
      firstUserId: event.currentUserId,
      secondUserId: event.otherUserId,
    );
    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (room) => emit(ChatRoomCreated(room)),
    );
  }

  Future<void> _onSubscribeToChatChannel(
    SubscribeToChatChannel event,
    Emitter<ChatState> emit,
  ) async {
    // Initialize Pusher if not already done
    if (!_pusherInitialized) {
      try {
        final token = await authLocalService.getToken();
        if (token != null && token.isNotEmpty) {
          print('🔌 Initializing Pusher...');
          await pusherConfig.init(
            token,
            'user-id', // You might want to get this from AuthBloc
            (messageData) {
              // Handle incoming real-time messages
              print('📨 Received real-time message: $messageData');
              add(ReceiveMessage(messageData));
            },
          );
          _pusherInitialized = true;
          print('✅ Pusher initialized successfully');
        }
      } catch (e) {
        print('❌ Error initializing Pusher: $e');
      }
    }

    // Subscribe to the specific room channel
    try {
      await pusherConfig.subscribeToRoom(event.roomId);
      print('✅ Subscribed to chat room: ${event.roomId}');
    } catch (e) {
      print('❌ Error subscribing to room: $e');
    }
  }

  Future<void> _onUnsubscribeFromChatChannel(
    UnsubscribeFromChatChannel event,
    Emitter<ChatState> emit,
  ) async {
    await pusherConfig.unsubscribeFromRoom(event.roomId);
  }

  Future<void> _onReceiveMessage(
    ReceiveMessage event,
    Emitter<ChatState> emit,
  ) async {
    // Parse the message data into a ChatMessage model
    try {
      print('📥 Received message event: ${event.messageData}');
      final message = ChatMessageModel.fromJson(event.messageData);
      print('✅ Parsed message: id=${message.id}, content=${message.content}');

      // If we are currently viewing the room this message belongs to, add it
      if (state is ChatMessagesLoaded) {
        final currentState = state as ChatMessagesLoaded;
        print(
          '📝 Current room: ${currentState.roomId}, messages count: ${currentState.messages.length}',
        );

        // Check if message already exists to avoid duplicates
        final messageExists = currentState.messages.any(
          (m) => m.id == message.id,
        );
        if (messageExists) {
          print('⚠️ Message ${message.id} already exists, skipping');
          return;
        }

        final updatedMessages = List<ChatMessage>.from(currentState.messages)
          ..add(message);
        print('🔄 Emitting new state with ${updatedMessages.length} messages');
        emit(
          ChatMessagesLoaded(
            messages: updatedMessages,
            roomId: currentState.roomId,
          ),
        );
      } else {
        print('⚠️ Not in ChatMessagesLoaded state, current state: $state');
      }
    } catch (e, stackTrace) {
      print('❌ Error parsing received message: $e');
      print('Stack trace: $stackTrace');
    }
  }

  Future<void> _onResetChatState(
    ResetChatState event,
    Emitter<ChatState> emit,
  ) async {
    print('🔄 Resetting chat state to initial');
    emit(ChatInitial());
  }
}
