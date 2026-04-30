import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'database.dart';

void main() async {
  await Database.init();
  final app = Router();

  // Users
  app.get('/api/all-users', Database.getAllUsers);
  app.get('/api/users', Database.getUsers);
  app.get('/api/users/<id>', Database.getUser);
  app.put('/api/users/<id>', Database.updateUser);
  app.put('/api/users/<userId>/role', Database.updateUserRole);
  app.get('/api/users/<userId>/transactions', Database.getUserTransactions);
  
  // Auth
  app.post('/api/auth/register', Database.register);
  app.post('/api/auth/login', Database.login);
  
  // Menu CRUD
  app.get('/api/menu', Database.getMenuItems);
  app.post('/api/menu', Database.createMenuItem);
  app.put('/api/menu/<id>', Database.updateMenuItem);
  app.delete('/api/menu/<id>', Database.deleteMenuItem);
  
  // ← Events CRUD (НОВОЕ)
  app.get('/api/events', Database.getEvents);
  app.post('/api/events', Database.createEvent);
  app.put('/api/events/<id>', Database.updateEvent);
  app.delete('/api/events/<id>', Database.deleteEvent);
  
  // Purchases
  app.post('/api/purchases', Database.addPurchase);
  
  // Stats
  app.get('/api/stats', Database.getStats);

  final handler = Pipeline()
      .addMiddleware(corsHeaders())
      .addMiddleware(logRequests())
      .addHandler(app.call);

  // ignore: unused_local_variable
  await io.serve(handler, '0.0.0.0', 8081);
  
  print('\n🚀 Backend запущен: http://0.0.0.0:8081');
  print('📁 Data: ${Database.dbPath}\n');
}