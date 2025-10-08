<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Group Spin Pro - Pembagi Kelompok Berkelanjutan (Simulasi)</title>
    <style>
        /* --- CSS Inline --- */
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 20px;
            background-color: #f4f7f6;
            color: #333;
        }
        .container {
            max-width: 900px;
            margin: 0 auto;
            background: #fff;
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 6px 15px rgba(0, 0, 0, 0.1);
        }
        h1, h2 {
            color: #007bff;
            border-bottom: 2px solid #e9ecef;
            padding-bottom: 10px;
            margin-bottom: 20px;
        }
        textarea, input[type="number"] {
            width: 100%;
            padding: 10px;
            margin-bottom: 15px;
            border: 1px solid #ccc;
            border-radius: 6px;
            box-sizing: border-box;
        }
        button {
            background-color: #28a745;
            color: white;
            padding: 12px 20px;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-size: 16px;
            transition: background-color 0.3s;
        }
        button:hover {
            background-color: #218838;
        }
        .section {
            margin-bottom: 30px;
            padding: 20px;
            border: 1px solid #ddd;
            border-radius: 8px;
            background-color: #fafafa;
        }
        .group-result {
            margin-top: 20px;
            border-top: 1px dashed #ccc;
            padding-top: 15px;
        }
        .group-result h3 {
            color: #007bff;
            margin-bottom: 8px;
        }
        .history-item {
            border: 1px solid #eee;
            padding: 10px;
            margin-bottom: 10px;
            border-left: 5px solid #007bff;
            cursor: pointer;
        }
        .history-item:hover {
            background-color: #e9f7ff;
        }
        .interaction-matrix table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 15px;
        }
        .interaction-matrix th, .interaction-matrix td {
            border: 1px solid #ddd;
            padding: 8px;
            text-align: center;
            font-size: 12px;
        }
        .interaction-matrix th {
            background-color: #f0f8ff;
            color: #333;
            font-weight: bold;
        }
        .low-interaction { background-color: #d4edda; } /* Hijau Muda */
        .high-interaction { background-color: #f8d7da; } /* Merah Muda */
    </style>
</head>
<body>

    <div class="container">
        <h1>Group Spin Pro 🤖</h1>
        <p>Alat Pembagi Kelompok dengan Pelacakan Riwayat Interaksi. (Data disimpan di browser)</p>

        <div class="section">
            <h2>1. Data Mahasiswa</h2>
            <p>Masukkan nama mahasiswa, dipisahkan oleh baris baru (Enter):</p>
            <textarea id="studentList" rows="6" placeholder="Contoh:&#10;Budi Hartono&#10;Citra Dewi&#10;Dedi Kusuma&#10;..."></textarea>
            <button onclick="saveStudents()">Simpan Daftar Mahasiswa</button>
            <p id="studentCount" style="margin-top: 10px; font-weight: bold;"></p>
        </div>

        <div class="section">
            <h2>2. Pembagian Kelompok</h2>
            <label for="groupSize">Jumlah Anggota per Kelompok:</label>
            <input type="number" id="groupSize" value="4" min="2">
            <button onclick="doGroupSpin()">Mulai Pembagian Kelompok (SPIN!)</button>

            <div class="group-result" id="groupResult">
                </div>
        </div>

        <div class="section">
            <h2>3. Matriks Interaksi & Riwayat 📊</h2>
            <p><strong>Matriks Interaksi:</strong> Menunjukkan seberapa sering (jumlah kali) dua mahasiswa pernah berkelompok bersama.</p>
            <div class="interaction-matrix" id="interactionMatrix">
                </div>
            
            <h3 style="margin-top: 25px;">Riwayat Pembagian</h3>
            <div id="historyList">
                </div>
        </div>
    </div>

    <script>
        const STORAGE_KEY_STUDENTS = 'groupSpin_students';
        const STORAGE_KEY_HISTORY = 'groupSpin_history';
        const STORAGE_KEY_MATRIX = 'groupSpin_matrix';

        // --- Fungsi Helper untuk Data ---

        function getStudents() {
            const data = localStorage.getItem(STORAGE_KEY_STUDENTS);
            return data ? JSON.parse(data) : [];
        }

        function getHistory() {
            const data = localStorage.getItem(STORAGE_KEY_HISTORY);
            return data ? JSON.parse(data) : [];
        }

        function getInteractionMatrix() {
            const data = localStorage.getItem(STORAGE_KEY_MATRIX);
            // Default ke objek kosong jika belum ada
            return data ? JSON.parse(data) : {}; 
        }

        function saveStudents() {
            const textarea = document.getElementById('studentList').value;
            const names = textarea.split('\n').map(name => name.trim()).filter(name => name.length > 0);
            
            // Inisialisasi Matriks Interaksi jika daftar baru
            const oldStudents = getStudents().map(s => s.name);
            const newNames = names.filter(name => !oldStudents.includes(name));
            if (newNames.length > 0) {
                 // Perlu diperbaharui, tapi di sini kita hanya fokus menyimpan nama
            }


            const studentObjects = names.map((name, index) => ({ id: index + 1, name: name }));
            localStorage.setItem(STORAGE_KEY_STUDENTS, JSON.stringify(studentObjects));
            
            alert(`Berhasil menyimpan ${studentObjects.length} mahasiswa.`);
            updateStudentCount(studentObjects.length);
            loadDataAndRender(); // Render matriks baru
        }
        
        function updateStudentCount(count) {
            document.getElementById('studentCount').textContent = `Total Mahasiswa: ${count}`;
        }

        // --- Fungsi Utama Pembagian Kelompok ---

        function doGroupSpin() {
            const students = getStudents();
            const groupSize = parseInt(document.getElementById('groupSize').value);

            if (students.length === 0 || isNaN(groupSize) || groupSize < 2) {
                alert("Pastikan ada mahasiswa dan ukuran kelompok minimal 2.");
                return;
            }
            if (groupSize > students.length) {
                 alert("Ukuran kelompok tidak boleh melebihi jumlah mahasiswa.");
                return;
            }

            // 1. Acak (Shuffle) Daftar Mahasiswa
            // Menggunakan algoritma Fisher-Yates untuk pengacakan yang adil
            let shuffledStudents = [...students];
            for (let i = shuffledStudents.length - 1; i > 0; i--) {
                const j = Math.floor(Math.random() * (i + 1));
                [shuffledStudents[i], shuffledStudents[j]] = [shuffledStudents[j], shuffledStudents[i]];
            }

            // 2. Bagi ke dalam Kelompok
            const groups = [];
            let groupIndex = 1;
            for (let i = 0; i < shuffledStudents.length; i += groupSize) {
                // Menangani sisa (remainder) anggota, masukkan ke kelompok terakhir
                const group = shuffledStudents.slice(i, i + groupSize);
                groups.push({ name: `Kelompok ${groupIndex++}`, members: group });
            }
            
            // Jika ada sisa, redistribusi ke kelompok sebelumnya (optional)
            // Di sini kita biarkan kelompok terakhir memiliki anggota yang kurang jika ada sisa.

            // 3. Simpan Riwayat dan Update Matriks Interaksi
            const newHistoryItem = {
                timestamp: new Date().toLocaleString(),
                groups: groups.map(g => ({ name: g.name, memberNames: g.members.map(m => m.name) }))
            };

            updateInteractionMatrix(groups.map(g => g.members));
            saveHistory(newHistoryItem);

            // 4. Tampilkan Hasil
            renderGroupResult(groups);
            renderInteractionMatrix();
            renderHistoryList();
        }

        // --- Fungsi Penyimpanan Riwayat dan Matriks ---

        function saveHistory(newHistoryItem) {
            const history = getHistory();
            history.unshift(newHistoryItem); // Tambahkan ke awal
            localStorage.setItem(STORAGE_KEY_HISTORY, JSON.stringify(history));
        }

        function updateInteractionMatrix(currentGroups) {
            let matrix = getInteractionMatrix();

            for (const group of currentGroups) {
                const members = group.map(m => m.name);
                // Iterasi semua pasangan unik dalam satu kelompok
                for (let i = 0; i < members.length; i++) {
                    for (let j = i + 1; j < members.length; j++) {
                        const nameA = members[i];
                        const nameB = members[j];

                        // Buat Kunci unik dan konsisten (misal: "Nama1|Nama2" di mana Nama1 < Nama2)
                        const key = [nameA, nameB].sort().join('|');

                        // Tambahkan hitungan
                        matrix[key] = (matrix[key] || 0) + 1;
                    }
                }
            }

            localStorage.setItem(STORAGE_KEY_MATRIX, JSON.stringify(matrix));
            return matrix;
        }

        // --- Fungsi Rendering UI ---

        function renderGroupResult(groups) {
            const resultDiv = document.getElementById('groupResult');
            let html = `<h3>Hasil Pembagian (${new Date().toLocaleTimeString()}):</h3>`;
            
            groups.forEach((group, index) => {
                const memberNames = group.members.map(m => m.name);
                html += `
                    <p style="font-weight: bold; color: #dc3545;">${group.name}:</p>
                    <p>${memberNames.join(', ')}</p>
                `;
            });
            resultDiv.innerHTML = html;
        }

        function renderInteractionMatrix() {
            const matrixDiv = document.getElementById('interactionMatrix');
            const students = getStudents().map(s => s.name);
            const matrixData = getInteractionMatrix();

            if (students.length < 2) {
                matrixDiv.innerHTML = "<p>Daftar mahasiswa terlalu sedikit untuk Matriks Interaksi.</p>";
                return;
            }

            let html = '<table><thead><tr><th></th>';
            students.forEach(s => html += `<th>${s}</th>`);
            html += '</tr></thead><tbody>';

            students.forEach((rowName, rowIndex) => {
                html += `<tr><th>${rowName}</th>`;
                students.forEach((colName, colIndex) => {
                    if (rowIndex === colIndex) {
                        html += '<td style="background-color: #f8f9fa;">-</td>'; // Diagonal
                    } else if (rowIndex > colIndex) {
                        html += '<td></td>'; // Kosongkan bagian bawah diagonal (mirror)
                    } else {
                        // Ambil jumlah interaksi
                        const key = [rowName, colName].sort().join('|');
                        const count = matrixData[key] || 0;
                        
                        // Klasifikasi warna (Contoh: > 2 kali dianggap high-interaction)
                        const className = count > 2 ? 'high-interaction' : (count === 0 ? 'low-interaction' : '');
                        
                        html += `<td class="${className}">${count}</td>`;
                    }
                });
                html += '</tr>';
            });

            html += '</tbody></table>';
            matrixDiv.innerHTML = html;
        }

        function renderHistoryList() {
            const historyListDiv = document.getElementById('historyList');
            const history = getHistory();

            if (history.length === 0) {
                historyListDiv.innerHTML = "<p>Belum ada riwayat pembagian kelompok.</p>";
                return;
            }

            let html = '';
            history.forEach((item, index) => {
                html += `
                    <div class="history-item" onclick="showHistoryDetail(${index})">
                        <strong>Pembagian ke-${history.length - index}</strong> | ${item.timestamp}
                        <div id="detail-${index}" style="display: none; margin-top: 10px; padding: 5px; border-top: 1px dotted #ccc;">
                            </div>
                    </div>
                `;
            });

            historyListDiv.innerHTML = html;
        }

        function showHistoryDetail(index) {
            const history = getHistory();
            const item = history[index];
            const detailDiv = document.getElementById(`detail-${index}`);
            
            if (detailDiv.style.display === 'block') {
                detailDiv.style.display = 'none';
                return;
            }

            let detailHtml = '';
            item.groups.forEach(group => {
                detailHtml += `<p><strong>${group.name}:</strong> ${group.memberNames.join(', ')}</p>`;
            });
            
            detailDiv.innerHTML = detailHtml;
            detailDiv.style.display = 'block';
        }

        // --- Inisialisasi Saat Halaman Dimuat ---

        function loadDataAndRender() {
            const students = getStudents();
            const studentsText = students.map(s => s.name).join('\n');
            document.getElementById('studentList').value = studentsText;
            updateStudentCount(students.length);
            renderHistoryList();
            renderInteractionMatrix();
        }

        window.onload = loadDataAndRender;

    </script>

</body>
</html>
