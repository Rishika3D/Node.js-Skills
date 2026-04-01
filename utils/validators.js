const Joi = require('joi');

// Validation schema for adding a school
const addSchoolSchema = Joi.object({
  name: Joi.string().required().min(2).max(255),
  address: Joi.string().required().min(5).max(500),
  latitude: Joi.number().required().min(-90).max(90),
  longitude: Joi.number().required().min(-180).max(180)
});

// Validation schema for listing schools
const listSchoolsSchema = Joi.object({
  latitude: Joi.number().required().min(-90).max(90),
  longitude: Joi.number().required().min(-180).max(180)
});

// Validate add school request
const validateAddSchool = (data) => {
  return addSchoolSchema.validate(data);
};

// Validate list schools request
const validateListSchools = (data) => {
  return listSchoolsSchema.validate(data);
};

module.exports = {
  validateAddSchool,
  validateListSchools
};
