-- Add location coordinates to businesses table
ALTER TABLE businesses 
ADD COLUMN latitude DECIMAL(10, 8) NULL AFTER address,
ADD COLUMN longitude DECIMAL(11, 8) NULL AFTER latitude;

-- Add geofencing settings to business_settings table
ALTER TABLE business_settings 
ADD COLUMN enable_geofencing BOOLEAN DEFAULT FALSE AFTER enable_games,
ADD COLUMN geofence_radius_meters INT DEFAULT 50 AFTER enable_geofencing;
