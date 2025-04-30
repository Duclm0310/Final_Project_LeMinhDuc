const { DataTypes } = require('sequelize');

module.exports = (sequelize, schema) =>{
    const DeviceToken = sequelize.define('DeviceToken', {
        id: {
            type: DataTypes.UUID,
            defaultValue: DataTypes.UUIDV4,
            primaryKey: true,
            allowNull: false
        },
        user_id: {
            type: DataTypes.UUID,
            allowNull: false,
        },
        device_token: {
            type: DataTypes.STRING,
            allowNull: false,
            unique: true
        },
        device_type: {
            type: DataTypes.ENUM('Android', 'Ios'),
            allowNull: false,
            defaultValue: 'Android'
        },
        created_at: {
            type: DataTypes.DATE,
            defaultValue: DataTypes.NOW
        },
        updated_at: {
            type: DataTypes.DATE,
            defaultValue: DataTypes.NOW
        }
    }, {
        tableName: 'device_tokens',
        timestamps: true,
        createdAt: 'created_at',
        updatedAt: 'updated_at'
    });
    
    
    DeviceToken.associate = (models) => {
        DeviceToken.belongsTo(models.User, {
             foreignKey: 'user_id',
              onDelete: 'CASCADE' 
            });

        models.User.hasMany(DeviceToken, { foreignKey: 'user_id' });
    };

    return DeviceToken;
}





