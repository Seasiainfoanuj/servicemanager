class CreateVehicleLogsView < ActiveRecord::Migration
  def up
    execute "DROP VIEW IF EXISTS vehicle_logs_views;"
    execute %{
      CREATE VIEW vehicle_logs_views AS
        SELECT vehicle_logs.id, vehicle_logs.vehicle_id, vehicle_logs.uid,
               vehicle_logs.service_provider_id, vehicle_logs.name, vehicle_logs.odometer_reading,
               date_format(vehicle_logs.updated_at, '%d/%m/%Y %I:%i %p') AS updated_at, vehicles.vehicle_number,
               vehicle_makes.name AS make_name, vehicle_models.name AS model_name, vehicle_models.year,
               vehicles.rego_number, vehicles.stock_number, vehicles.kit_number, vehicles.call_sign, vehicles.vin_number,
               workorders.uid AS workorder_uid, workorder_types.name AS workorder_type, users.id AS user_id,
               CONCAT(users.first_name, ' ', users.last_name, ' ', users.company) AS service_provider_name, users.email

        FROM vehicle_logs
        LEFT JOIN vehicles on vehicles.id = vehicle_logs.vehicle_id
        LEFT JOIN users on vehicle_logs.service_provider_id = users.id
        LEFT JOIN vehicle_models on vehicles.vehicle_model_id = vehicle_models.id
        LEFT JOIN vehicle_makes on vehicle_models.vehicle_make_id = vehicle_makes.id
        LEFT JOIN workorders on vehicle_logs.workorder_id = workorders.id
        LEFT JOIN workorder_types on workorders.workorder_type_id = workorder_types.id
      }
  end

  def down
    execute "DROP VIEW IF EXISTS vehicle_logs_views;"
  end
end
