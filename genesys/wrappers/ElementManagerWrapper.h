/*
 * Copyright (C) 2019 Telmo "Trooper" <telmo.trooper@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/* 
 * File:   ElementManagerWrapper.h
 * Author: Telmo "Trooper" <telmo.trooper@gmail.com>
 *
 * Created on October 14, 2019, 11:18 PM
 */

#ifndef ELEMENT_MANAGER_WRAPPER_H
#define ELEMENT_MANAGER_WRAPPER_H

#include "../ElementManager.h"
#include <pybind11/pybind11.h>
namespace py = pybind11;

void initElementManager(py::module &m) {
    py::class_<ElementManager>(m, "ElementManager")
        .def(py::init<Model*>())
        .def("insert", &ElementManager::insert)
        .def("remove", &ElementManager::remove)
//        .def("check", &ElementManager::check)
        .def("clear", &ElementManager::clear)
//        .def("getElement", &ElementManager::getElement)
//        .def("getNumberOfElements", &ElementManager::getNumberOfElements)
        .def("getRankOf", &ElementManager::getRankOf)
        .def("getElementTypenames", &ElementManager::getElementTypenames);
}

#endif /* ELEMENT_MANAGER_WRAPPER_H */

