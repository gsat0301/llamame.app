-- Migration 003: Add hero and popup ad types
-- Run this in the Supabase SQL editor after 002_gallery_ratings.sql

ALTER TYPE public.ad_type ADD VALUE IF NOT EXISTS 'hero';
ALTER TYPE public.ad_type ADD VALUE IF NOT EXISTS 'popup';
