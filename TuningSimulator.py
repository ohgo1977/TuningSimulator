# ------------------------------------------------------------------------
# File Name   : TuningSimulator.py
# Description : Training Simulator to tune and match an NMR probe.
# Requirement : tkinter, numpy, matplotlib
# Developer   : Dr. Kosuke Ohgo
# ULR         : https://github.com/ohgo1977/TuningSimulator
# Version     : 1.0.0
# 
# Please read the manual (README_TuningSimulator.pdf) for details.
# %
# % ------------------------------------------------------------------------
# 
# MIT License
#
# Copyright (c) 2025 Kosuke Ohgo
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#
# Revision Information
# Version 1.0.0
# December 17, 2025
#  - Initial Submission

import tkinter as tk
from tkinter import ttk
import numpy as np

from matplotlib.figure import Figure
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg


class TuningSimulator:
    """
    Training Simulator to tune and match an NMR probe.
    Tkinter + Matplotlib version
    """

    # ------------------------------------------------------------
    # Initialization
    # ------------------------------------------------------------
    def __init__(self, root):
        self.root = root
        self.root.title("Tuning Simulator")

        self.initialize_state()
        self.build_ui()
        self.plot()

    # ------------------------------------------------------------
    # State initialization (MATLAB: initialize)
    # ------------------------------------------------------------
    def initialize_state(self):
        self.init_switch = 1
        self.size_no = 180

        self.x_p_ini = (np.random.rand() - 0.5) * 2 * self.size_no
        self.y_p_ini = (np.random.rand() - 0.5) * 2 * self.size_no

        self.x_p_vec = []
        self.y_p_vec = []

        self.min_record = 1.0
        self.M_ang_Quad = np.random.randint(0, 4)

        self.v_T = 0
        self.v_M = 0

    # ------------------------------------------------------------
    # UI construction
    # ------------------------------------------------------------
    def build_ui(self):
        # ---- Main layout ----
        self.mainframe = ttk.Frame(self.root)
        self.mainframe.pack(fill=tk.BOTH, expand=True)

        # ---- Control panel ----
        ctrl = ttk.Frame(self.mainframe)
        ctrl.pack(side=tk.LEFT, fill=tk.Y, padx=5, pady=5)

        # ---- Tuning buttons ----
        ttk.Label(ctrl, text="Tuning").pack(pady=(5, 0))

        self.make_button(ctrl, "<", lambda: self.ui_pb(1))
        self.make_button(ctrl, "<<", lambda: self.ui_pb(2))
        self.make_button(ctrl, ">", lambda: self.ui_pb(3))
        self.make_button(ctrl, ">>", lambda: self.ui_pb(4))

        ttk.Separator(ctrl).pack(fill=tk.X, pady=5)

        # ---- Matching buttons ----
        ttk.Label(ctrl, text="Matching").pack(pady=(5, 0))

        self.make_button(ctrl, "<", lambda: self.ui_pb(5))
        self.make_button(ctrl, "<<", lambda: self.ui_pb(6))
        self.make_button(ctrl, ">", lambda: self.ui_pb(7))
        self.make_button(ctrl, ">>", lambda: self.ui_pb(8))

        ttk.Separator(ctrl).pack(fill=tk.X, pady=5)

        # ---- Refresh ----
        ttk.Button(ctrl, text="Refresh", command=self.refresh).pack(pady=5)

        # ---- Checkboxes ----
        ttk.Label(ctrl, text="Display").pack(pady=(10, 0))

        self.show_2d = tk.BooleanVar(value=True)
        self.show_sweep = tk.BooleanVar(value=True)
        self.show_ref_l = tk.BooleanVar(value=True)
        self.show_ref_s = tk.BooleanVar(value=True)

        ttk.Checkbutton(ctrl, text="2D Map",
                        variable=self.show_2d,
                        command=self.plot).pack(anchor=tk.W)

        ttk.Checkbutton(ctrl, text="Sweep",
                        variable=self.show_sweep,
                        command=self.plot).pack(anchor=tk.W)

        ttk.Checkbutton(ctrl, text="Reflection (L)",
                        variable=self.show_ref_l,
                        command=self.plot).pack(anchor=tk.W)

        ttk.Checkbutton(ctrl, text="Reflection (S)",
                        variable=self.show_ref_s,
                        command=self.plot).pack(anchor=tk.W)

        # ---- Matplotlib figure ----
        self.fig = Figure(figsize=(9, 6))
        self.canvas = FigureCanvasTkAgg(self.fig, master=self.mainframe)
        self.canvas.get_tk_widget().pack(side=tk.RIGHT, fill=tk.BOTH, expand=True)

    def make_button(self, parent, text, cmd):
        ttk.Button(parent, text=text, command=cmd).pack(fill=tk.X, pady=2)

    # ------------------------------------------------------------
    # Button callback (MATLAB: ui_pb)
    # ------------------------------------------------------------
    def ui_pb(self, pb_v):
        s_step = 1
        l_step = 10

        if pb_v == 1:
            self.v_T -= s_step
        elif pb_v == 2:
            self.v_T -= l_step
        elif pb_v == 3:
            self.v_T += s_step
        elif pb_v == 4:
            self.v_T += l_step
        elif pb_v == 5:
            self.v_M -= s_step
        elif pb_v == 6:
            self.v_M -= l_step
        elif pb_v == 7:
            self.v_M += s_step
        elif pb_v == 8:
            self.v_M += l_step

        self.plot()

    def refresh(self):
        self.initialize_state()
        self.plot()

    # ------------------------------------------------------------
    # Plot logic (MATLAB: plot)
    # ------------------------------------------------------------
    def plot(self):
        self.fig.clear()

        # Interaction parameters
        T_ang = 5
        M_ang = 150

        x_p = (self.x_p_ini +
               np.cos(np.deg2rad(T_ang)) * self.v_T +
               np.cos(np.deg2rad(M_ang)) * self.v_M)

        y_p = (self.y_p_ini +
               np.sin(np.deg2rad(T_ang)) * self.v_T +
               np.sin(np.deg2rad(M_ang)) * self.v_M)

        self.x_p_vec.append(x_p)
        self.y_p_vec.append(y_p)

        x_vec = np.arange(-self.size_no, self.size_no + 1)
        y_vec = np.arange(-self.size_no, self.size_no + 1)
        x_mat, y_mat = np.meshgrid(x_vec, y_vec)

        obj_ang = 90
        w1 = 8
        w2 = 1.2 + 0.02 * np.abs(y_mat - y_p)

        xp = x_mat - x_p
        yp = y_mat - y_p

        z_mat = -1.0 / (
            w1 * w2 +
            (np.cos(np.deg2rad(obj_ang)) * xp +
             np.sin(np.deg2rad(obj_ang)) * yp) ** 2 / w1 ** 2 +
            (-np.sin(np.deg2rad(obj_ang)) * xp +
             np.cos(np.deg2rad(obj_ang)) * yp) ** 2 / w2 ** 2
        )

        if self.init_switch == 1:
            self.max_z_mat = np.max(np.abs(z_mat))

        z_mat = z_mat / self.max_z_mat + 1

        c = self.size_no
        min_ref = z_mat[c, c]
        self.min_record = min(self.min_record, min_ref)

        subplot_idx = 1

        if self.show_2d.get():
            ax = self.fig.add_subplot(2, 2, subplot_idx)
            ax.contour(x_mat, y_mat, z_mat, levels=np.linspace(0, 1, 11))
            ax.plot(self.x_p_vec, self.y_p_vec, 'r')
            ax.axhline(0)
            ax.axvline(0, linestyle='--')
            ax.set_title("2D Map")
            subplot_idx += 1

        if self.show_sweep.get():
            ax = self.fig.add_subplot(2, 2, subplot_idx)
            ax.plot(x_vec, z_mat[c, :])
            ax.axvline(0, linestyle='--')
            ax.plot(0, min_ref, 'ro')
            ax.plot(0, self.min_record, 'co')
            ax.set_ylim(-0.1, 1.1)
            ax.set_title("Sweep (mtune)")
            subplot_idx += 1

        if self.show_ref_l.get():
            ax = self.fig.add_subplot(2, 2, subplot_idx)
            ax.plot([0, 1], [min_ref]*2, 'r')
            ax.plot([0, 1], [self.min_record]*2, 'c--')
            ax.set_ylim(-0.1, 1.1)
            ax.set_title("Reflection (L)")
            subplot_idx += 1

        if self.show_ref_s.get():
            ax = self.fig.add_subplot(2, 2, subplot_idx)
            ax.plot([0, 1], [min_ref]*2, 'r')
            ax.plot([0, 1], [self.min_record]*2, 'c--')
            ax.set_ylim(-0.1, 0.3)
            ax.set_title("Reflection (S)")

        self.init_switch += 1
        self.canvas.draw_idle()


# ------------------------------------------------------------
# Run simulator
# ------------------------------------------------------------
if __name__ == "__main__":
    root = tk.Tk()
    app = TuningSimulator(root)
    root.mainloop()
