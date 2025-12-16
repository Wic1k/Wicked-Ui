// api/keys.js - Размести в папке /api на autoblock.vercel.app
// Этот файл использует Vercel KV для хранения ключей

import { kv } from '@vercel/kv';

const EXPIRATION_TIME = 48 * 60 * 60 * 1000; // 48 часов в миллисекундах

export default async function handler(req, res) {
  // Разрешаем CORS
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  // POST - Создание нового ключа
  if (req.method === 'POST') {
    try {
      const { key, createdAt } = req.body;

      if (!key) {
        return res.status(400).json({ error: 'Key is required' });
      }

      // Сохраняем ключ с временной меткой
      await kv.set(key, {
        createdAt: createdAt || Date.now(),
        valid: true
      });

      // Устанавливаем автоматическое удаление через 48 часов
      await kv.expire(key, 48 * 60 * 60); // TTL в секундах

      return res.status(201).json({
        success: true,
        message: 'Key created successfully',
        key: key,
        expiresIn: '48 hours'
      });

    } catch (error) {
      console.error('Error creating key:', error);
      return res.status(500).json({ error: 'Internal server error' });
    }
  }

  // GET - Проверка ключа (для Lua скрипта)
  if (req.method === 'GET') {
    try {
      const { key } = req.query;

      if (!key) {
        return res.status(400).json({ 
          valid: false, 
          error: 'Key parameter is required' 
        });
      }

      // Получаем данные ключа
      const keyData = await kv.get(key);

      if (!keyData) {
        return res.status(404).json({
          valid: false,
          error: 'Key not found or expired'
        });
      }

      // Проверяем, не истек ли срок действия
      const now = Date.now();
      const timePassed = now - keyData.createdAt;
      
      if (timePassed > EXPIRATION_TIME) {
        await kv.del(key); // Удаляем устаревший ключ
        return res.status(410).json({
          valid: false,
          error: 'Key has expired'
        });
      }

      const timeLeft = EXPIRATION_TIME - timePassed;
      const hoursLeft = Math.floor(timeLeft / (60 * 60 * 1000));
      const minutesLeft = Math.floor((timeLeft % (60 * 60 * 1000)) / (60 * 1000));

      return res.status(200).json({
        valid: true,
        key: key,
        timeLeft: `${hoursLeft}h ${minutesLeft}m`,
        expiresAt: keyData.createdAt + EXPIRATION_TIME
      });

    } catch (error) {
      console.error('Error validating key:', error);
      return res.status(500).json({ 
        valid: false, 
        error: 'Internal server error' 
      });
    }
  }

  return res.status(405).json({ error: 'Method not allowed' });
}


// ============================================
// АЛЬТЕРНАТИВНЫЙ ВАРИАНТ БЕЗ VERCEL KV
// api/keys-simple.js
// ============================================

// Этот вариант использует простое хранилище в памяти
// Подходит для тестирования, но ключи сбросятся при перезапуске

const keys = new Map();

export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  const EXPIRATION_TIME = 48 * 60 * 60 * 1000;

  // Очистка устаревших ключей
  const cleanupExpiredKeys = () => {
    const now = Date.now();
    for (const [key, data] of keys.entries()) {
      if (now - data.createdAt > EXPIRATION_TIME) {
        keys.delete(key);
      }
    }
  };

  if (req.method === 'POST') {
    try {
      const { key, createdAt } = req.body;

      if (!key) {
        return res.status(400).json({ error: 'Key is required' });
      }

      cleanupExpiredKeys();

      keys.set(key, {
        createdAt: createdAt || Date.now(),
        valid: true
      });

      return res.status(201).json({
        success: true,
        message: 'Key created successfully',
        key: key,
        expiresIn: '48 hours'
      });

    } catch (error) {
      console.error('Error creating key:', error);
      return res.status(500).json({ error: 'Internal server error' });
    }
  }

  if (req.method === 'GET') {
    try {
      const { key } = req.query;

      if (!key) {
        return res.status(400).json({ 
          valid: false, 
          error: 'Key parameter is required' 
        });
      }

      cleanupExpiredKeys();

      const keyData = keys.get(key);

      if (!keyData) {
        return res.status(404).json({
          valid: false,
          error: 'Key not found or expired'
        });
      }

      const now = Date.now();
      const timePassed = now - keyData.createdAt;
      
      if (timePassed > EXPIRATION_TIME) {
        keys.delete(key);
        return res.status(410).json({
          valid: false,
          error: 'Key has expired'
        });
      }

      const timeLeft = EXPIRATION_TIME - timePassed;
      const hoursLeft = Math.floor(timeLeft / (60 * 60 * 1000));
      const minutesLeft = Math.floor((timeLeft % (60 * 60 * 1000)) / (60 * 1000));

      return res.status(200).json({
        valid: true,
        key: key,
        timeLeft: `${hoursLeft}h ${minutesLeft}m`,
        expiresAt: keyData.createdAt + EXPIRATION_TIME
      });

    } catch (error) {
      console.error('Error validating key:', error);
      return res.status(500).json({ 
        valid: false, 
        error: 'Internal server error' 
      });
    }
  }

  return res.status(405).json({ error: 'Method not allowed' });
}
